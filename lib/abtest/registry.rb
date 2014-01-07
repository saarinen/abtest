module Abtest
  # Register a test.  This method takes the view prefix of the directory 
  # where your view overrides are located (most often the gem name) and a lambda
  # that will be used to determine whether or not to enable your test.  The provided
  # lambda must return a truthy value for the test to be activated.
  def self.register_test prefix, lamb
    abtest_config.registered_tests.add({prefix: prefix, check: lamb})
  end

  def self.abtest_config
    Rails.application.config.abtest
  end
end