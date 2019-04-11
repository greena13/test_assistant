module TestAssistant
  autoload :Json, 'test_assistant/json/helpers'
  autoload :FailureReporter, 'test_assistant/failure_reporter'

  # Class that provides configuration methods to control what parts of Test Assistant
  # are included in an RSpec test suite. Instances of this class are managed internally
  # by Test Assistant when using the TestAssistant#configure method.
  #
  # @see TestAssistant#configure
  class Configuration
    # Creates a new TestAssistant::Configuration object - called internally by Test
    # Assistant
    #
    # @param rspec_config RSpec configuration object, available in the block passed to
    #   RSpec.configure
    # @return [TestAssistant::Configuration] new configuration object
    def initialize(rspec_config)
      @rspec_config = rspec_config
    end

    # Configures RSpec to include the JSON helpers provided by Test Assistant in the
    # the test suite's scope
    #
    # @see TestAssistant::Json::Helpers
    # @see RSpec::Core::Configuration#include
    #
    # @param [Hash] options RSpec::Core::Configuration#include options
    # @return void
    #
    # @example Include JSON helpers in your RSpec test suite
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.include_json_helpers
    #     end
    #   end
    def include_json_helpers(options = {})
      @rspec_config.include Json::Helpers, options
    end

    # Configures under what circumstances a failing test should open a failure report
    # detailing the last HTTP request and response in a browser
    #
    # @param [Hash{Symbol => Symbol,String,Boolean}] options filters for when a test
    #   failure should show a failure report
    # @option options [Symbol, Boolean] :tag The tag tests must be given in order to
    #   show a failure report. If false, no tag is needed and all tests that
    #   fail (and meet any other filter options provided) will show a failure report.
    # @option options [Symbol, Boolean] :type The RSpec test type for which a failure
    #   will show a failure report. If false, tests of any type that fail (and
    #   meet any other filter options provided) will show a failure report.
    # @return void
    #
    # @example Show a failure report for failing tests tagged with :focus
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.render_failed_response(tag: :focus)
    #     end
    #   end
    #
    # @example Show a failure report for all failing tests
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.render_failed_response(tag: false)
    #     end
    #   end
    #
    # @example Show a failure report for all failing controller tests
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.render_failed_response(type: :controller)
    #     end
    #   end
    #
    # @see TestAssistant::FailureReporter#report
    def render_failed_responses(options = {})
      tag_filter = options[:tag]
      no_tag_filter = !tag_filter

      type_filter = options[:type]
      no_type_filter = !type_filter

      @rspec_config.after(:each) do |example|
        next unless example.exception

        metadata = example.metadata
        next unless (metadata[tag_filter] || no_tag_filter) && (metadata[:type] == type_filter || no_type_filter)

        if metadata[:type] == :feature
          save_and_open_page
        else
          reporter = FailureReporter.report(request, response)
          reporter.write
          reporter.open
        end
      end
    end

    # Configures under what circumstances a failing test should open an debugger session
    #
    # @param [Hash{Symbol => Symbol,String,Boolean}] options filters for when a test
    #   failure should open a debugger session
    # @option options [Symbol, Boolean] :tag The tag tests must be given in order to
    #   open the debugger. If false, no tag is needed and any test that fails (and
    #   meets any other filter options provided) will open the debugger.
    # @option options [Symbol, Boolean] :type The type of test that should open the
    #   debugger if it fails. If false, no tag is needed and any test that fails (and
    #   meets any other filter options provided) will open the debugger.
    # @return void
    #
    # @example Open the debugger for failing tests tagged with :focus
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.debug_failed_responses(tag: :focus)
    #     end
    #   end
    #
    # @example Open the debugger for all failing tests
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.debug_failed_responses(tag: false)
    #     end
    #   end
    #
    # @example Open the debugger for all failing controller tests
    #   RSpec.configure do |config|
    #     TestAssistant.configure(config) do |ta_config|
    #       ta_config.debug_failed_responses(type: :controller)
    #     end
    #   end
    def debug_failed_responses(options = {})
      tag_filter = options.fetch(:tag, :debugger)
      type_filter = options[:type]
      no_type_filter = !type_filter

      @rspec_config.after(:each) do |example|
        next unless example.exception

        metadata = example.metadata
        next unless (metadata.key?(tag_filter)) && (metadata[:type] == type_filter || no_type_filter)

        # noinspection RubyResolve
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
