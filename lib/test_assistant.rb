require "test_assistant/version"
require 'test_assistant/configuration'

module TestAssistant
  class << self
    def configure(rspec_config)
      configuration = Configuration.new(rspec_config)

      if block_given?
        yield(configuration)
      end
    end

    alias :config :configure
  end

end
