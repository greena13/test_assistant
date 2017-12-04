require 'test_assistant/email/expectation'

module TestAssistant::Email
  # Module containing email helper methods that can be mixed into RSpec the test scope
  #
  # @see TestAssistant::Configuration#include_email_helpers
  module Helpers
    # Syntactic sugar for referencing the list of emails sent since the start of the test
    #
    # @return [Array<Mail::Message>] list of sent emails
    #
    # @example Asserting email has been sent
    #   expect(email).to have_been_sent.to('test@email.com')
    def email
      ActionMailer::Base.deliveries
    end

    # Clears the list of sent emails. Automatically called by Test Assistant at the
    # end of every test.
    #
    # @return void
    def clear_emails
      ActionMailer::Base.deliveries = []
    end

    # Creates a new email expectation that allows asserting emails should have specific
    # attributes.
    #
    # @see TestAssistant::Email::Expectation
    #
    # @example Asserting email has been sent
    #   expect(email).to have_been_sent.to('test@email.com')
    def have_been_sent
      TestAssistant::Email::Expectation.new
    end
  end
end
