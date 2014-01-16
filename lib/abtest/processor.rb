require 'rails'

module Abtest
  class Processor
    def self.process_tests controller

      experiment_activated  = false

      Abtest.abtest_config.registered_tests.each do |test_hash|
        app_config      = Rails.application.config
        environment     = Rails.application.assets
        experiment_name = test_hash[:name]
        experiment_path = Rails.root.join('abtest', 'experiments', experiment_name)

        if (test_hash[:check].call(controller.request)  && !experiment_activated)
          # ensure experimental translations are loaded
          unless (I18n.load_path || []).last.include?(experiment_name)
            I18n.load_path = app_config.i18n.load_path + Dir[Rails.root.join('abtest', 'experiments', experiment_name, 'config', 'locales', '*.{rb,yml}').to_s]
            I18n.reload!
          end

          # Set view context for asset path
          environment.context_class.assets_prefix = File.join(app_config.assets.prefix, 'experiments', experiment_name)
          ActionView::Base.assets_prefix = File.join(app_config.assets.prefix, 'experiments', experiment_name)

          manifest = Abtest::ManifestManager.instance.retrieve_manifest(experiment_name)

          ActionView::Base.assets_environment = manifest.environment
          ActionView::Base.assets_manifest    = manifest

          # Prepend the lookup paths for our views
          controller.prepend_view_path(File.join(experiment_path, 'views'))

          test_hash[:process].call(controller) unless test_hash[:process].nil?

          experiment_activated = true
        elsif (!experiment_activated)
          # ensure experimental translations are removed
          I18n.reload! if I18n.load_path.reject! { |path| path.include?(experiment_name) }

          environment.context_class.assets_prefix = File.join(app_config.assets.prefix)
          ActionView::Base.assets_prefix = File.join(app_config.assets.prefix)

          manifest_path = File.join(Rails.root, 'public', app_config.assets.prefix)

          if app_config.assets.compile
            ActionView::Base.assets_environment = environment
            ActionView::Base.assets_manifest    = Sprockets::Manifest.new(environment, manifest_path)
          else
            ActionView::Base.assets_manifest = Sprockets::Manifest.new(manifest_path)
          end
        end
      end
    end
  end
end
