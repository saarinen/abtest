require 'rails'

module Abtest
  class Processor
    def self.process_tests controller
      Abtest.abtest_config.registered_tests.each do |test_hash|
        if (test_hash[:check].call(controller.request))
          byebug
          controller.prepend_view_path(test_hash[:prefix])
        end
      end
    end
  end
end