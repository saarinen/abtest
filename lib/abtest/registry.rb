require "rails"

module Abtest
  # Register a test.  This method takes the view prefix of the directory 
  # where your view overrides are located (most often the gem name) and a lambda
  # that will be used to determine whether or not to enable your test.  The provided
  # lambda must return a truthy value for the test to be activated and accept a request object
  def self.register_test test_engine, lamb
    # Remove the default view path
    view_path = "#{test_engine.root}/app/views"
    ActionController::Base.view_paths = ActionController::Base.view_paths.reject {|path| path.to_path == view_path }
    abtest_config.registered_tests.add({prefix: view_path, check: lamb})
  end

  def self.abtest_config
    Rails.application.config.abtest
  end
end