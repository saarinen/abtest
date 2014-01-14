require 'sprockets/rails'
require 'byebug'

module Abtest
  class AssetTask < Sprockets::Rails::Task
    attr_accessor :app

    def initialize(app = nil)
      self.app = app
      super(app)
    end

    def define
      namespace :abtest do
        desc "Compile all the assets named in config.assets.precompile"
        task :precompile => :environment do
          configured_experiments = app.config.abtest.registered_tests

          # Precompile assets for each experiment
          configured_experiments.each do |experiment|
            name = experiment[:name]

            experiment_path       = File.join(app.root, 'abtest', 'experiments', name)
            application_css_path  = File.join(experiment_path, app.config.assets.prefix, 'stylesheets')
            images_path           = File.join(experiment_path, app.config.assets.prefix, 'images')
            javascript_path       = File.join(experiment_path, app.config.assets.prefix, 'javascript')

            # Create a custom sprockets environment
            experiment_environment = Sprockets::Environment.new(Rails.root.to_s) do |env|
              env.context_class.class_eval do
                include ::Sprockets::Rails::Helper
                assets_prefix = File.join('experiments', name)
              end
            end

            # Always calculate digests and compile files
            app.config.assets.digest      = true
            app.config.assets.compile     = true
            experiment_environment.cache  = :null_store  # Disables the Asset cache

            experiment_environment.prepend_path("#{application_css_path}")
            experiment_environment.prepend_path("#{images_path}")
            experiment_environment.prepend_path("#{javascript_path}")

            # Copy config.assets.paths to Sprockets
            app.config.assets.paths.each do |path|
              experiment_environment.append_path path
            end

            output_file = File.join(app.root, 'public', app.config.assets.prefix, 'experiments', name)
            app.config.assets.prefix = "/experiments/single_colunm/assets"

            manifest = Sprockets::Manifest.new(experiment_environment, output_file)

            with_logger do
              manifest.compile(assets)
            end
          end
        end
      end
    end
  end
end
