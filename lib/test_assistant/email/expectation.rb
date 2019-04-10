require 'capybara/rspec'

require 'test_assistant/email/email_filter'

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
  class Expectation < EmailFilter

    # Creates a new TestAssistant::Email::Expectation object
    #
    # @return [TestAssistant::Email::Expectation] new expectation object
    def initialize
      @failure_message = 'Expected email to be sent'
      super
    end

    # Declares that RSpec should not attempt to diff the actual and expected values
    # to put in the failure message. This class takes care of diffing and presenting
    # the differences, itself.
    # @return [false] always returns false
    def diffable?
      false
    end

    # Whether at least one email was sent during the current test that matches the
    # constructed expectation
    # @return [Boolean] whether a matching email was sent
    def matches?(emails)
      @emails = emails
      matching_emails(emails, @scopes).any?
    end

    # Message to display to StdOut by RSpec if the equality check fails. Includes a
    # complete a human-readable summary of the differences between what emails were
    # expected to be sent, and what were actually sent (if any). Only used when the
    # positive assertion is used, i.e. expect(email).to have_been_sent. For the
    # failure message used for negative assertions, i.e.
    # expect(email).to_not have_been_sent, see #failure_message_when_negated
    #
    # @see #failure_message_when_negated
    #
    # @return [String] message full failure message with explanation of the differences
    #   between what emails were expected and what was actually sent
    def failure_message
      attribute, expected_value =
        attribute_and_expected_value(@scopes, @emails)

      describe_failed_assertion(
        @emails,
        attribute,
        expected_value
      )
    end

    # Failure message to display for negative RSpec assertions, i.e.
    # expect(email).to_not have_been_sent. For the failure message displayed for positive
    # assertions, see #failure_message.
    #
    # @see #failure_message
    #
    # @return [String] message full failure message with explanation of the differences
    #   between what emails were expected and what was actually sent
    def failure_message_when_negated
      field_descs = attribute_descriptions(@scopes.keys)
      value_descs = value_descriptions(@scopes.values)

      expectation_description(
          'Expected no emails to be sent',
          field_descs,
          value_descs
      )
    end
  end
end
