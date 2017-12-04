require "test_assistant/version"
require 'test_assistant/configuration'

# Utility module for working with RSpec test suites for Rails or similar applications
#
# Contains:
# - Expressive syntax for asserting testing emails
# - Sophisticated JSON matchers and diff failure reports
# - Rendering and debugging tools for viewing test failures
#
# @see https://github.com/greena13/test_assistant Test Assistant Github page
module TestAssistant
  class << self
    # Configures what parts of TestAssistant are included in your test suite and how
    # they behave.
    #
    # @see TestAssistant::Configuration
    #
    # @param rspec_config RSpec configuration object available in RSpec.configure block
    # @return void
    def configure(rspec_config)
      configuration = Configuration.new(rspec_config)

      if block_given?
        yield(configuration)
      end
    end

    alias :config :configure
  end
end
