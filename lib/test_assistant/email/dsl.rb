module TestAssistant
  module Email
    module DSL
      def self.included(base)
        base.class_eval do
          # Creates a new TestAssistant::Email::EmailFilter object
          #
          # @return [TestAssistant::Email::EmailFilter] new expectation object
          def initialize
            @scopes = {}
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
              ArgumentError.new("Cannot use an and modifier without a proceeding assertion.")
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
            @scopes[:to] ||= []

            if email_address.kind_of?(Array)
              @scopes[:to] = @scopes[:to].concat(email_address)
            else
              @scopes[:to] ||= []
              @scopes[:to] << email_address
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
            if @scopes[:from]
              raise ArgumentError('An email can only have one from address, but you tried to assert the presence of 2 or more values')
            else
              @scopes[:from] = email_address
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
            if @scopes[:with_subject]
              raise ArgumentError('An email can only have one subject, but you tried to assert the presence of 2 or more values')
            else
              @scopes[:with_subject] = subject
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
            @scopes[:with_text] ||= []
            @scopes[:with_text].push(text)

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
            @scopes[:matching_selector] ||= []
            @scopes[:matching_selector].push(selector)

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
            @scopes[:with_link] ||= []
            @scopes[:with_link].push(href)

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
            @scopes[:with_image] ||= []
            @scopes[:with_image].push(src)

            @and_scope = :with_image
            self
          end
        end
      end
    end
  end
end

