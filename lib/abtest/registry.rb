require "rails"

module Abtest
  # Register a test.  This method takes the following parameters:
  # view_path:          View prefix of the directory where your view overrides are located 
  # test:               A lambda used to determine whether or not to activate this test.  The provided
  #                     lambda must return a truthy value for the test to be activated and accept a request object.
  # process (optional): Lambda to run in the case of a test being activated.  Will be passed the controller object.
  def self.register_test(view_path, test, process = nil)
    # If this path is already in the configured paths, remove it.
    # This is used mainly for engine based tests.
    ActionController::Base.view_paths = ActionController::Base.view_paths.reject {|path| path.to_path == view_path }
    abtest_config.registered_tests.add({prefix: view_path, check: test, process: process})
  end

  def self.abtest_config
    Rails.application.config.abtest
  end
end