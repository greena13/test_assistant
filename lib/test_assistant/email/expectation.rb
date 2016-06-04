require 'capybara/rspec'

module TestAssistant::Email
  class Expectation
    def initialize
      @expectations = {}
      @failure_message = 'Expected email to be sent'
      @and_scope = nil
    end

    MATCHERS = {
        to: :to,
        from: :from,
        with_subject: :subject,
        with_text: {
            match: ->(_, email, value){ value.all?{|text| email.has_content?(text) }},
            actual: ->(_, email){ email.text}
        },
        with_selector: {
            match: ->(_, email, value){ value.all?{|text| email.has_selector?(text) }},
            actual: ->(_, email){ email.native },
            actual_name: :with_body
        },
        with_link: {
            match: ->(_, email, value){ value.all?{|value| email.has_selector?("a[href='#{value}']") }},
            actual: ->(_, email){ email.native },
            actual_name: :with_body
        },
        with_image: {
            match: ->(_, email, value){ value.all?{|value| email.has_selector?("img[src='#{value}']") }},
            actual: ->(_, email){ email.native },
            actual_name: :with_body
        }
    }

    def and(*arguments)
      if @and_scope
        self.send(@and_scope, *arguments)
      else
        ArugmentError.new("Cannot use and without a proceeding assertion.")
      end
    end

    def to(email_address)
      if email_address.kind_of?(Array)
        @expectations[:to] = email_address
      else
        @expectations[:to] ||= []
        @expectations[:to] << email_address
      end

      @and_scope = :to

      self
    end

    def from(email_address)
      if email_address.kind_of?(Array)
        @expectations[:from] = email_address
      else
        @expectations[:from] ||= []
        @expectations[:from] << email_address
      end

      @and_scope = :from

      self
    end

    def with_subject(subject)
      if @expectations[:with_subject]
        raise ArgumentError('An email can only have one subject, but you tried to assert the presence of 2 or more values')
      else
        @expectations[:with_subject] = subject
      end

      self
    end

    def with_text(text)
      @expectations[:with_text] ||= []
      @expectations[:with_text].push(text)

      @and_scope = :with_text
      self
    end

    def with_selector(selector)
      @expectations[:with_selector] ||= []
      @expectations[:with_selector].push(selector)

      @and_scope = :with_selector
      self
    end

    def with_link(href)
      @expectations[:with_link] ||= []
      @expectations[:with_link].push(href)

      @and_scope = :with_link
      self
    end

    def with_image(src)
      @expectations[:with_image] ||= []
      @expectations[:with_image].push(src)

      @and_scope = :with_image
      self
    end

    def diffable?
      false
    end

    def matches?(emails)
      @emails = emails

      matching_emails = @emails

      @expectations.each do |attribute, expected|

        matching_emails =
            matching_emails.select do |email|
              email_matches?(email, MATCHERS[attribute], expected)
            end

        if matching_emails.empty?
          @failed_attribute = attribute
          @failed_expected = expected
          return false
        end
      end

      true
    end

    def failure_message
      field_description = @failed_attribute.to_s.gsub('_', ' ')
      value_description =
          case @failed_expected
            when String
              "'#{@failed_expected}'"
            when Array
              @failed_expected.map{|val| "'#{val}'"}.to_sentence
            else
              @failed_expected
          end

      base_clause = "Expected an email to be sent #{field_description} #{value_description}."

      if @emails.length == 0
        base_clause + ' However, no emails were sent.'
      else
        pluralisation = @emails.length == 1 ? 'email' : 'emails'

        email_values = @emails.inject([]) do |memo, email|
          matcher = MATCHERS[@failed_attribute]

          value =
              case matcher
                when String, Symbol
                  email.send(matcher)
                when Hash
                  field_description = matcher[:actual_name] if matcher[:actual_name]
                  matcher[:actual].(email, parsed_emails(email))
              end

          value = value.kind_of?(String) ? "'#{value}'" : value
          memo << value

          memo
        end


        if email_values.any?
          base_clause + " However, #{pluralisation} were sent #{field_description} #{email_values.to_sentence}"
        else
          base_clause
        end
      end
    end

    private

    def parsed_emails(email)
      @parsed_emails ||= {}
      @parsed_emails[email] ||= parser(email)
      @parsed_emails[email]
    end

    def parser(email)
      Capybara::Node::Simple.new(email.parts.first.body.decoded)
    end

    def email_matches?(email, assertion, expected)
      case assertion
        when String, Symbol
          email.send(assertion) == expected
        when Hash
          assertion[:match].(email, parsed_emails(email), expected)
        else
          raise RuntimeError.new(
              "Unsupported assertion mapping '#{assertion_match}' of type #{assertion_match.class.name}"
          )
      end
    end
  end
end
