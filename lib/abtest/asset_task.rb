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
            name      = experiment[:name]
            manifest  = Abtest::ManifestManager.instance.retrieve_manifest(name)

            # Add our experiments asset path
            assets << lambda {|filename, path| path =~ /#{name}\/assets/ && !%w(.js .css).include?(File.extname(filename))}

            with_logger do
              manifest.compile(assets)
            end
          end
        end
      end
    end
  end
end