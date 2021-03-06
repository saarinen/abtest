require 'rails'

module Abtest
  class Railtie < ::Rails::Railtie
    rake_tasks do |app|
      require 'abtest/asset_task'
      Abtest::AssetTask.new(app)
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end

    initializer "abtest.set_config", :after => 'bootstrap_hook' do
      config.abtest                   = ActiveSupport::OrderedOptions.new
      config.abtest.registered_tests  = Set.new
      config.abtest.precompile_assets = Array.new
    end

    initializer "abtest.set_filter" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Abtest::Filters)
      end

      module ActionView
        module Rendering
          module ClassMethods
            def view_context
              view_context_class.new(view_renderer, view_assigns, self)
            end
          end
        end
      end
    end
  end
end

