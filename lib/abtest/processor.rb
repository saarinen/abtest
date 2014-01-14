require 'rails'

module Abtest
  class Processor
    def self.process_tests controller

      experiment_activated  = false

      Abtest.abtest_config.registered_tests.each do |test_hash|
        app_config            = Rails.application.config
        environment           = Rails.application.assets
        experiment_path       = File.join(Rails.root, 'abtest', 'experiments', test_hash[:name])

        application_css_path = File.join(experiment_path, app_config.assets.prefix, 'stylesheets')
        images_path          = File.join(experiment_path, app_config.assets.prefix, 'images')
        javascript_path      = File.join(experiment_path, app_config.assets.prefix, 'javascript')

        if (test_hash[:check].call(controller.request)  && !experiment_activated)
          # Set view context for asset path
          environment.context_class.assets_prefix = File.join(app_config.assets.prefix, 'experiments', test_hash[:name])
          ActionView::Base.assets_prefix = File.join(app_config.assets.prefix, 'experiments', test_hash[:name])

          # Swap out our manifest file
          manifest_path       = File.join(Rails.root, 'public', app_config.assets.prefix, 'experiments', test_hash[:name])
          if app_config.assets.compile
            ActionView::Base.assets_manifest = Sprockets::Manifest.new(environment, manifest_path)
          else
            ActionView::Base.assets_manifest = Sprockets::Manifest.new(manifest_path)
          end

          # Add asset paths
          environment.prepend_path("#{application_css_path}")
          environment.prepend_path("#{images_path}")
          environment.prepend_path("#{javascript_path}")
          environment.index

          # Prepend the lookup paths for our views
          controller.prepend_view_path(File.join(experiment_path, 'views'))

          test_hash[:process].call(controller) unless test_hash[:process].nil?

          experiment_activated = true
        end
      end
    end

    def self.cleanup_tests controller
      app_config            = Rails.application.config
      environment           = Rails.application.assets

      # Set view context for asset path
      environment.context_class.assets_prefix = app_config.assets.prefix
      ActionView::Base.assets_prefix  = File.join(app_config.assets.prefix)
      manifest_path                   = File.join(Rails.root, 'public', app_config.assets.prefix)

      unless ActionView::Base.assets_manifest.dir == manifest_path
        if app_config.assets.compile
          ActionView::Base.assets_manifest = Sprockets::Manifest.new(environment, manifest_path)
        else
          ActionView::Base.assets_manifest = Sprockets::Manifest.new(manifest_path)
        end
      end

      Abtest.abtest_config.registered_tests.each do |test_hash|
        experiment_path      = File.join(Rails.root, 'abtest', 'experiments', test_hash[:name])

        core_paths = environment.paths.dup.reject { |path| path.starts_with?(experiment_path) }
        environment.clear_paths
        core_paths.each do |path|
          environment.append_path path
        end
        environment.index
      end
    end
  end
end
