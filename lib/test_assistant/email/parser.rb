module TestAssistant
  module Email
    module Parser
      def parsed_emails(email)
        parser(email)
      end

      def parser(email)
        Capybara::Node::Simple.new(email_body(email))
      end

      def email_body(email)
        if email.parts.first
          email.parts.first.body.decoded
        else
          email.body.encoded
        end
      end
    end
  end
end
