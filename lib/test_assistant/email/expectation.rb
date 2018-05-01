require 'capybara/rspec'

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
  class Expectation
    MATCHERS = {
        to: :to,
        from: :from,
        with_subject: :subject,
        with_text: {
            match: ->(_, email, value){ value.all?{|text| email.has_content?(text) }},
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

    # Creates a new TestAssistant::Email::Expectation object
    #
    # @return [TestAssistant::Email::Expectation] new expectation object
    def initialize
      @expectations = {}
      @failure_message = 'Expected email to be sent'
      @and_scope = nil
    end

    #
    # Expectation creation methods
    #

    # Allows chaining two assertions on the same email attribute together without having
    # to repeat the same method. Intended as syntactical sugar only and is functionally
    # equivalent to repeating the method.
    #
    # @example Asserting an email was sent to two email addresses
    #   expect(email).to have_been_sent.to('user1@email.com').and('user2@email.com')
    #
    # @param [Array] arguments parameters to pass to whatever assertion is being
    #   extended.
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def and(*arguments)
      if @and_scope
        self.send(@and_scope, *arguments)
      else
        ArugmentError.new("Cannot use and without a proceeding assertion.")
      end
    end

    # For constructing an assertion that at least one email was sent to a particular
    # email address
    #
    # @example Asserting an email was sent to user@email.com
    #   expect(email).to have_been_sent.to('user@email.com')
    #
    # @param [String, Array<String>] email_address address email is expected to be
    #   sent to. If an array of email addresses, the email is expected to have been
    #   sent to all of them.
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def to(email_address)
      @expectations[:to] ||= []

      if email_address.kind_of?(Array)
        @expectations[:to] = @expectations[:to].concat(email_address)
      else
        @expectations[:to] ||= []
        @expectations[:to] << email_address
      end

      @and_scope = :to

      self
    end

    # For constructing an assertion that at least one email was sent from a particular
    # email address
    #
    # @example Asserting an email was sent from admin@site.com
    #   expect(email).to have_been_sent.from('admin@site.com')
    #
    # @param [String] email_address address email is expected to be sent from.
    # @raise ArgumentError when from is called more than once on the same expectation,
    #   as an email can only ben sent from a single sender.
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def from(email_address)
      if @expectations[:from]
        raise ArgumentError('An email can only have one from address, but you tried to assert the presence of 2 or more values')
      else
        @expectations[:from] = email_address
      end

      @and_scope = :from

      self
    end

    # For constructing an assertion that at least one email was sent with a particular
    # subject line
    #
    # @example Asserting an email was sent with subject line 'Hello'
    #   expect(email).to have_been_sent.with_subject('Hello')
    #
    # @param [String] subject Subject line an email is expected to have been sent with
    # @raise ArgumentError when with_subject is called more than once on the same
    #   expectation, as an email can only have one subject line.
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def with_subject(subject)
      if @expectations[:with_subject]
        raise ArgumentError('An email can only have one subject, but you tried to assert the presence of 2 or more values')
      else
        @expectations[:with_subject] = subject
      end

      @and_scope = :with_subject

      self
    end

    # For constructing an assertion that at least one email was sent with a particular
    # string in the body of the email
    #
    # @example Asserting an email was sent with the text 'User 1'
    #   expect(email).to have_been_sent.with_text('User 1')
    #
    # @param [String] text Text an email is expected to have been sent with in the body
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def with_text(text)
      @expectations[:with_text] ||= []
      @expectations[:with_text].push(text)

      @and_scope = :with_text
      self
    end

    # For constructing an assertion that at least one email was sent with a body that
    # matches a particular CSS selector
    #
    # @example Asserting an email was sent with a body matching selector '#imporant-div'
    #   expect(email).to have_been_sent.matching_selector('#imporant-div')
    #
    # @param [String] selector CSS selector that should match at least one sent
    #   email's body
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def matching_selector(selector)
      @expectations[:matching_selector] ||= []
      @expectations[:matching_selector].push(selector)

      @and_scope = :matching_selector
      self
    end

    # For constructing an assertion that at least one email was sent with a link to
    # a particular url in the body
    #
    # @example Asserting an email was sent with a link to http://www.example.com
    #   expect(email).to have_been_sent.with_link('http://www.example.com')
    #
    # @param [String] href URL that should appear in at least one sent email's body
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def with_link(href)
      @expectations[:with_link] ||= []
      @expectations[:with_link].push(href)

      @and_scope = :with_link
      self
    end

    # For constructing an assertion that at least one email was sent with an image
    # hosted at a particular URL
    #
    # @example Asserting an email was sent with the image http://www.example.com/image.png
    #   expect(email).to have_been_sent.with_link('http://www.example.com/image.png')
    #
    # @param [String] src URL of the image that should appear in at least one sent
    #   email's body
    # @return [TestAssistant::Email::Expectation] reference to self, to allow for
    #   further method chaining
    def with_image(src)
      @expectations[:with_image] ||= []
      @expectations[:with_image].push(src)

      @and_scope = :with_image
      self
    end

    #
    # RSpec Matcher methods
    #

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

    # Failure message to display for negative RSpec assertions, i.e.
    # expect(email).to_not have_been_sent. For the failure message displayed for positive
    # assertions, see #failure_message.
    #
    # @see #failure_message
    #
    # @return [String] message full failure message with explanation of the differences
    #   between what emails were expected and what was actually sent
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

          value = value.kind_of?(String) ? "'#{value}'" : value.map{|element| "'#{element}'"}
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
      if email.parts.first
        email.parts.first.body.decoded
      else
        email.body.encoded
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
              "Unsupported assertion mapping '#{assertion_match}' of type #{assertion_match.class.name}"
          )
      end
    end
  end
end
