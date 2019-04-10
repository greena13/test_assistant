require 'capybara/rspec'

require 'test_assistant/email/dsl'
require 'test_assistant/email/failure_descriptions'
require 'test_assistant/email/matchers'

module TestAssistant::Email
  # Backing class for have_been_sent declarative syntax for specifying email
  # expectations. Provides ability to assert emails have been sent in a given test
  # that match particular attribute values, such as sender, receiver or contents.
  #
  # Expected to be used as part of a RSpec test suite and with
  # TestAssistant::Email::Helpers#email.
  #
  # Has two major components:
  # - A Builder or chainable methods syntax for constructing arbitrarily specific
  #   expectations
  # - An implementation of the same interface as RSpec custom matcher classes to
  #   allow evaluating those expectations those expectations
  #
  # @see TestAssistant::Email::Helpers#email
  # @see TestAssistant::Email::Helpers#have_been_sent
  class EmailFilter
    include DSL
    include Matchers
    include FailureDescriptions
  end
end
