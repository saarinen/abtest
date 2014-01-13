require 'rails'

module Abtest
  class Processor
    def self.process_tests controller

      experiment_activated  = false

      Abtest.abtest_config.registered_tests.each do |test_hash|
        app_config            = Rails.application.config
        environment           = Rails.application.assets
        experiment_path       = File.join(Rails.root, 'abtest', 'experiments', test_hash[:name])

        if (test_hash[:check].call(controller.request)  && !experiment_activated)
          # Set view cotext for asset path
          environment.context_class.assets_prefix = File.join(app_config.assets.prefix, 'experiments', test_hash[:name])
          ActionView::Base.assets_prefix = File.join(app_config.assets.prefix, 'experiments', test_hash[:name])

          # Swap out our manifest file
          manifest_path       = File.join(Rails.root, 'public', app_config.assets.prefix, 'experiments', test_hash[:name])
          if app_config.assets.compile
            ActionView::Base.assets_manifest = Sprockets::Manifest.new(environment, manifest_path)
          else
            ActionView::Base.assets_manifest = Sprockets::Manifest.new(manifest_path)
          end

          # Prepend the lookup paths for our views
          controller.prepend_view_path(File.join(Rails.root, 'experiments', test_hash[:name], 'views'))

          test_hash[:process].call(controller) unless test_hash[:process].nil?

          experiment_activated = true
        end

        # Set our manifest and asset path back to default unless we have an active experiment
        unless experiment_activated
          # Set view cotext for asset path
          environment.context_class.assets_prefix = app_config.assets.prefix
          ActionView::Base.assets_prefix  = File.join(app_config.assets.prefix, 'experiments', test_hash[:name])

          manifest_path                   = File.join(Rails.root, 'public', app_config.assets.prefix)
          unless ActionView::Base.assets_manifest.dir == manifest_path
            if app_config.assets.compile
              ActionView::Base.assets_manifest = Sprockets::Manifest.new(environment, manifest_path)
            else
              ActionView::Base.assets_manifest = Sprockets::Manifest.new(manifest_path)
            end
          end
        end
      end
    end
  end
end