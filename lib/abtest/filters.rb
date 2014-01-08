module Abtest
  module Filters
    extend ActiveSupport::Concern

    included do
      append_before_filter :process_abtests
    end

    def process_abtests
      Abtest::Processor.process_tests(self)
    end
  end
end