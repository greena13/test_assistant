module TestAssistant::JSONHelpers
  def json_response
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      '< INVALID JSON RESPONSE >'.freeze
    end
  end
end
