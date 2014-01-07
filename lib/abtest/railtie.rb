require 'rails'

module Abtest
  class Railtie < ::Rails::Railtie
    initializer "abtest.set_config", :after => 'bootstrap_hook' do
      config.abtest = ActiveSupport::OrderedOptions.new
      config.abtest.registered_tests = Set.new
    end

    initializer "abtest.set_filter", :after => 'bootstrap_hook' do
      ActionController::Base.class_eval do
        include Abtest
        append_before_filter Abtest::Processor.process_tests
      end
    end
  end
end

