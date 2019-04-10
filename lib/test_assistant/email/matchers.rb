require 'test_assistant/email/parser'

module TestAssistant
  module Email
    module Matchers
      include Parser

      MATCHERS = {
        to: :to,
        from: :from,
        with_subject: :subject,
        with_text: {
          match: ->(_, email, value){ value.all?{|text| email.has_text?(text) }},
          actual: ->(_, email){ email.text}
        },
        matching_selector: {
          match: ->(_, email, value){ value.all?{|selector| email.has_selector?(selector) }},
          actual: ->(_, email){ email.native },
          actual_name: :with_body
        },
        with_link: {
          match: ->(_, email, value){ value.all?{|url| email.has_selector?("a[href='#{url}']") }},
          actual: ->(_, email){ email.native },
          actual_name: :with_body
        },
        with_image: {
          match: ->(_, email, value){ value.all?{|url| email.has_selector?("img[src='#{url}']") }},
          actual: ->(_, email){ email.native },
          actual_name: :with_body
        }
      }

      def self.included(base)
        base.class_eval do
          def matching_emails(emails, scopes)
            if scopes.any?
              emails.select do |email|
                scopes.all? do |attribute, expected|
                  email_matches?(email, MATCHERS[attribute], expected)
                end
              end
            else
              emails
            end
          end

          def email_matches?(email, assertion, expected)
            case assertion
            when :to
              (expected & email.send(assertion)).length > 0
            when String, Symbol
              email.send(assertion).include?(expected)
            when Hash
              assertion[:match].(email, parsed_emails(email), expected)
            else
              raise RuntimeError.new(
                "Unsupported assertion mapping '#{assertion}' of type #{assertion.class.name}"
              )
            end
          end
        end
      end
    end
  end
end
