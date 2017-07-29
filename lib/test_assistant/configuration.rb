module TestAssistant
  autoload :Json, 'test_assistant/json/helpers'
  autoload :Email, 'test_assistant/email/helpers'
  autoload :FailureReporter, 'test_assistant/failure_reporter'

  class Configuration
    def initialize(rspec_config)
      @rspec_config = rspec_config
    end

    def include_json_helpers(options = {})
      @rspec_config.include Json::Helpers, options
    end

    def include_email_helpers(options = {})
      @rspec_config.include Email::Helpers, options

      @rspec_config.after :each do
        clear_emails
      end
    end

    def render_failed_responses(options = {})
      tag_filter = options[:tag]
      no_tag_filter = !tag_filter
      type_filter = options[:type]
      no_type_filter = !type_filter

      @rspec_config.after(:each) do |example|
        if example.exception
          if (example.metadata[tag_filter] || no_tag_filter) && (example.metadata[:type] == type_filter || no_type_filter)
            reporter = FailureReporter.report(request, response)
            reporter.write
            reporter.open
          end
        end
      end
    end

    def debug_failed_responses(options = {})
      tag_filter = options.fetch(:tag, :debugger)
      type_filter = options[:type]
      no_type_filter = !type_filter

      @rspec_config.after(:each) do |example|
        if example.exception
          if (example.metadata[tag_filter]) && (example.metadata[:type] == type_filter || no_type_filter)
            if defined? binding
              binding.pry
            elsif defined? byebug
              byebug
            else
              debugger
            end
          end
        end
      end
    end
  end
end
