require "abtest/version"
require "abtest/railtie"
require "abtest/processor"
require "abtest/registry"
require "abtest/filters"
require "abtest/asset"
require 'rails'

module Abtest
  class ManifestManager
    include Singleton
    attr_accessor :manifests

    def initialize
      @manifests = {}
    end

    def retrieve_manifest name
      manifests[name] ||= create_manifest(name)
    end

    def create_manifest name
      app                   = Rails.application
      experiment_path       = File.join(app.root, 'abtest', 'experiments', name)
      application_css_path  = File.join(experiment_path, app.config.assets.prefix, 'stylesheets')
      images_path           = File.join(experiment_path, app.config.assets.prefix, 'images')
      javascript_path       = File.join(experiment_path, app.config.assets.prefix, 'javascript')

      # Create a custom sprockets environment
      experiment_environment = Sprockets::Environment.new(Rails.root.to_s) do |env|
        env.context_class.class_eval do
          include ::Sprockets::Rails::Helper
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

      experiment_environment.js_compressor  = app.config.assets.js_compressor
      experiment_environment.css_compressor = app.config.assets.css_compressor

      output_file                                         = File.join(app.root, 'public', app.config.assets.prefix, 'experiments', name)
      experiment_environment.context_class.assets_prefix  = "#{app.config.assets.prefix}/experiments/#{name}"
      experiment_environment.context_class.digest_assets  = app.config.assets.digest
      experiment_environment.context_class.config         = app.config.action_controller

      manifests[name] = Sprockets::Manifest.new(experiment_environment, output_file)
    end
  end
end
