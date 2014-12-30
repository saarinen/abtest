module Abtest
  module Filters
    extend ActiveSupport::Concern

    included do
      append_before_filter :process_abtests
    end

    def process_abtests
      experiment_activated  = false

      Abtest.abtest_config.registered_tests.each do |test_hash|
        app_config      = Rails.application.config
        environment     = Rails.application.assets
        experiment_name = test_hash[:name]
        experiment_path = Rails.root.join('abtest', 'experiments', experiment_name)

        if (test_hash[:check].call(request)  && !experiment_activated)
          # ensure experimental translations are loaded
          unless (I18n.load_path || []).last.include?(experiment_name)
            I18n.load_path = app_config.i18n.load_path + Dir[Rails.root.join('abtest', 'experiments', experiment_name, 'config', 'locales', '*.{rb,yml}').to_s]
            I18n.reload!
          end

          manifest = Abtest::ManifestManager.instance.retrieve_manifest(experiment_name)

          # Set view context for asset path
          view_context_class.assets_prefix       = File.join(app_config.assets.prefix, 'experiments', experiment_name)
          view_context_class.assets_environment  = manifest.environment
          view_context_class.assets_manifest     = manifest

          # Prepend the lookup paths for our views
          prepend_view_path(File.join(experiment_path, 'views'))

          test_hash[:process].call(binding) unless test_hash[:process].nil?

          experiment_activated = true
        elsif (!experiment_activated)
          # ensure experimental translations are removed
          I18n.reload! if I18n.load_path.reject! { |path| path.include?(experiment_name) }
        end
      end

      unless experiment_activated
        # Use default manifest
        manifest = Abtest::ManifestManager.instance.retrieve_manifest('default')

        # Set view context for asset path
        view_context_class.assets_prefix       = File.join(Rails.application.config.assets.prefix)
        view_context_class.assets_environment  = manifest.environment
        view_context_class.assets_manifest     = manifest
      end
    end
  end
end
