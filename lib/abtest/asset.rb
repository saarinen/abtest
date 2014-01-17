module Sprockets
  class Base
    def find_asset(path, options = {})
      logical_path = path
      pathname     = Pathname.new(path)

      if pathname.absolute?
        return unless stat(pathname)
        logical_path = attributes_for(pathname).logical_path
      else
        begin
          pathname = resolve(logical_path)

          # If logical path is missing a mime type extension, append
          # the absolute path extname so it has one.
          #
          # Ensures some consistency between finding "foo/bar" vs
          # "foo/bar.js".
          if File.extname(logical_path) == ""
            expanded_logical_path = attributes_for(pathname).logical_path
            logical_path += File.extname(expanded_logical_path)
          end
        rescue FileNotFound
          # Check to see if we are in an experiment
          if (path.starts_with?("experiments"))
            Abtest.abtest_config.registered_tests.each do |test_hash|
              if (path.starts_with?("experiments/#{test_hash[:name]}"))
                # Strip experiment path
                experiment_path = path.sub("experiments/#{test_hash[:name]}/", '')

                # Grab experiment manifest
                manifest        = Abtest::ManifestManager.instance.retrieve_manifest(test_hash[:name])
                return manifest.environment.index.find_asset(experiment_path, options)
              end
            end
          end
          return nil
        end
      end

      build_asset(logical_path, pathname, options)
    end
  end
end