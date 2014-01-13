require "rails"

module Abtest
  # Register a test.  This method takes the following parameters:
  # name:               Name of the experiment.
  # test:               A lambda used to determine whether or not to activate this test.  The provided
  #                     lambda must return a truthy value for the test to be activated and accept a request object.
  # process (optional): Lambda to run in the case of a test being activated.  Will be passed the controller object.
  def self.register_test(name, test, process = nil)
    abtest_config.registered_tests.add({name: name, check: test, process: process})
  end

  def self.abtest_config
    Rails.application.config.abtest
  end
end