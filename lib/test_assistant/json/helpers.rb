require 'test_assistant/json/expectation'

module TestAssistant::Json
  module Helpers
    def json_response
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        '< INVALID JSON RESPONSE >'.freeze
      end
    end

    def eql_json(expected)
      TestAssistant::Json::Expectation.new(expected)
    end
  end
end
