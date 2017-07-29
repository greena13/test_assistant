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
        matching_selector: {
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
      if @expectations[:from]
        raise ArgumentError('An email can only have one from address, but you tried to assert the presence of 2 or more values')
      else
        @expectations[:from] = email_address
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

      @and_scope = :with_subject

      self
    end

    def with_text(text)
      @expectations[:with_text] ||= []
      @expectations[:with_text].push(text)

      @and_scope = :with_text
      self
    end

    def matching_selector(selector)
      @expectations[:matching_selector] ||= []
      @expectations[:matching_selector].push(selector)

      @and_scope = :matching_selector
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

      if @expectations.any?
        @expectations.each do |attribute, expected|
          @failed_attribute = attribute
          @failed_expected = expected

          matching_emails =
              matching_emails.select do |email|
                email_matches?(email, MATCHERS[attribute], expected)
              end

          if matching_emails.empty?
            return false
          end
        end

        true
      else
        @emails.any?
      end
    end

    def failure_message
      field_descs = attribute_descriptions
      value_descs = value_descriptions

      base_clause = expectation_description(
          'Expected an email to be sent',
          field_descs,
          value_descs
      )

      if @emails.length == 0
        "#{base_clause} However, no emails were sent."
      else
        email_values = sent_email_values

        if email_values.any?
          base_clause + " However, #{email_pluralisation(@emails)} sent #{result_description(field_descs, [to_sentence(email_values)])}."
        else
          base_clause
        end
      end
    end

    def result_description(field_descriptions, values)
      to_sentence(
        field_descriptions.map.with_index do |field_description, index|
          value = values[index]

          if [ 'matching selector', 'with link', 'with image' ].include?(field_description)
            "with body #{value}"
          else
            "#{field_description} #{value}"
          end
        end
      )
    end

    def failure_message_when_negated
      field_descs = attribute_descriptions(negated: true)
      value_descs = value_descriptions(negated: true)

      expectation_description(
          'Expected no emails to be sent',
          field_descs,
          value_descs
      )
    end

    private

    def sent_email_values
      @emails.inject([]) do |memo, email|

        if [ :matching_selector, :with_link, :with_image ].include?(@failed_attribute)
          memo << email_body(email)
        else
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
        end

        memo
      end
    end

    def expectation_description(base_clause, field_descriptions, value_descriptions)
      description = base_clause

      additional_clauses = []

      field_descriptions.each.with_index do |field_description, index|
        clause = ''
        clause += " #{field_description}" if field_description.length > 0

        if (value_description = value_descriptions[index])
          clause += " #{value_description}"
        end

        additional_clauses.push(clause) if clause.length > 0
      end

      description + additional_clauses.join('') + '.'
    end

    def attribute_descriptions(negated: false)
      attributes_to_describe =
          if negated
            @expectations.keys
          else
            [ @failed_attribute ]
          end

      attributes_to_describe.map do |attribute|
          attribute.to_s.gsub('_', ' ')
      end
    end

    def value_descriptions(negated: false)
      values_to_describe =
          if negated
            @expectations.values
          else
            [ @failed_expected ]
          end

      values_to_describe.map do |value|
        case value
        when String
          "'#{value}'"
        when Array
          to_sentence(value.map{|val| "'#{val}'"})
        else
          value
        end
      end

    end

    def email_pluralisation(emails)
      emails.length > 2 ? "#{emails.length} were": "1 was"
    end

    def to_sentence(items)
      case items.length
      when 0, 1
        items.join('')
      when 2
        items.join(' and ')
      else
        items[0..(items.length-3)].join(', ') + items[(items.length-3)..items.length-1].join(' and ')
      end
    end

    def parsed_emails(email)
      @parsed_emails ||= {}
      @parsed_emails[email] ||= parser(email)
      @parsed_emails[email]
    end

    def parser(email)
      Capybara::Node::Simple.new(email_body(email))
    end

    def email_body(email)
      email.parts.first.body.decoded
    end

    def email_matches?(email, assertion, expected)
      case assertion
        when :to
          expected.include?(email.send(assertion))
        when String, Symbol
          expected == email.send(assertion)
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
