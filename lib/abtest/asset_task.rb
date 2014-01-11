require 'sprockets/rails'
require 'byebug'

module Abtest
  class AssetTask < Sprockets::Rails::Task
    attr_accessor :app

    def initialize(app = nil)
      self.app = app
      super(app)
    end

    def environment
      if app
        app.assets
      else
        super
      end
    end

    def output
      if app
        File.join(app.root, 'public', app.config.assets.prefix)
      else
        super
      end
    end

    def assets
      if app
        app.config.assets.precompile
      else
        super
      end
    end

    def cache_path
      if app
        "#{app.config.root}/tmp/cache/assets"
      else
        @cache_path
      end
    end
    attr_writer :cache_path

    def define
      namespace :abtest do
        desc "Compile all the assets named in config.assets.precompile"
        task :precompile, [:name] => :environment do |t, args| 
          name = args[:name]
          puts "Experiment name is required" and return if name.nil?

          with_logger do
            manifest.clean(keep)
          end

          experiment_path       = "#{Rails.root}/experiments/#{name}"
          application_css_path  = "#{experiment_path}/assets/#{name}/stylesheets"
          images_path           = "#{experiment_path}/assets/#{name}/images"

          # Always calculate digests and compile files
          app.config.assets.digest = true
          app.config.assets.compile = true

          assets += [Proc.new do |path|
            unless path =~ /\.(css|js)\z/
              full_path = app.assets.resolve(path).to_path
              app_assets_path = "#{experiment_path}/assets/"
              if full_path.starts_with? app_assets_path
                true
              else
                false
              end
            else
              false
            end
          end, "application.css"]

          environment.prepend_path("#{application_css_path}")
          environment.prepend_path("#{images_path}")

          manifest = Sprockets::Manifest.new(environment, output)

          with_logger do
            manifest.compile(assets)
          end
        end
      end
    end
  end
end