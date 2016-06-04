require 'test_assistant/email/expectation'

module TestAssistant::Email
  module Helpers
    def email
      ActionMailer::Base.deliveries
    end

    def have_been_sent
      TestAssistant::Email::Expectation.new
    end
  end
end
