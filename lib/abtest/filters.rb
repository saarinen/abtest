module Abtest
  module Filters
    extend ActiveSupport::Concern

    included do
      append_before_filter :process_abtests
      append_after_filter  :cleanup_abtests
    end

    def process_abtests
      Abtest::Processor.process_tests(self)
    end

    def cleanup_abtests
      Abtest::Processor.cleanup_tests(self)
    end
  end
end
