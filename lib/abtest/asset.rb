module Sprockets
  class Environment < Base
    def find_asset(path, options = {})
      options[:bundle] = true unless options.key?(:bundle)

      # Ensure inmemory cached assets are still fresh on every lookup
      if (asset = @assets[cache_key_for(path, options)]) && asset.fresh?(self)
        asset
      elsif asset = index.find_asset(path, options)
        # Cache is pushed upstream by Index#find_asset
        asset
      elsif (path.starts_with?("experiments"))
        Abtest.abtest_config.registered_tests.each do |test_hash|
          if (path.starts_with?("experiments/#{test_hash[:name]}"))
            environment           = ::Rails.application.assets
            app_config            = ::Rails.application.config
            test_root             = File.join(::Rails.root, 'abtest')
            experiment_path       = File.join(test_root, 'experiments', test_hash[:name])
            application_css_path  = File.join(experiment_path, app_config.assets.prefix, 'stylesheets')
            images_path           = File.join(experiment_path, app_config.assets.prefix, 'images')
            javascript_path       = File.join(experiment_path, app_config.assets.prefix, 'javascript')

            core_paths  = environment.paths.dup
            core_cache  = environment.cache

            environment.prepend_path(application_css_path)
            environment.prepend_path(images_path)
            environment.prepend_path(javascript_path)
            environment.cache = :null_store

            # Reset index
            environment.index

            # Strip experiment path
            experiment_path = path.sub("experiments/#{test_hash[:name]}/", '')

            asset = index.find_asset(experiment_path, options)

            # Reset paths
            environment.clear_paths
            core_paths.each do |path|
              environment.append_path path
            end
            environment.index
            environment.cache = core_cache
            return asset
          end
        end
      end
    end
  end
end