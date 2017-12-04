require 'test_assistant/json/expectation'

module TestAssistant::Json
  # Module containing JSON helper methods that can be mixed into RSpec the test scope
  #
  # @see TestAssistant::Configuration#include_json_helpers
  module Helpers
    # Parses the last response body in a Rails RSpec controller or request test as JSON
    #
    # @return [Hash{String => String, Number, Hash, Array}] Ruby representation of
    #   the JSON response body
    # @raise []JSON::ParserError] when the response body is not valid JSON
    def json_response
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        '< INVALID JSON RESPONSE >'.freeze
      end
    end

    # Creates a new TestAssistant::Json::Expectation instance so it can be passed
    # to RSpec to match against an actual value.
    #
    # @see TestAssistant::Expectation
    #
    # @param expected the expected value the RSpec matcher should match against
    # @return [TestAssistant::Json::Expectation] new expectation object
    #
    # @example Use the eql_json expectation
    #   expect(actual).to eql_json(expected)
    #
    # @example Use the eql_json expectation with json_response
    #   expect(json_response).to eql_json(expected)
    def eql_json(expected)
      TestAssistant::Json::Expectation.new(expected)
    end
  end
end
