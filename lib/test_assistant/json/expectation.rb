require 'capybara/rspec'
require 'hashdiff'

module TestAssistant::Json
  class Expectation
    def initialize(expected)
      @expected = expected
    end

    def diffable?
      false
    end

    def matches?(actual)
      @actual = actual
      @expected.eql?(@actual)
    end

    def failure_message
      message = ''
      message += "Expected: #{@expected}\n\n"
      message += "Actual: #{@actual}\n\n"
      message += "Differences\n\n"

      differences = HashDiff.diff(@actual, @expected)

      differences.each do |difference|
        operator, *operands = difference

        case operator
          when '-'
            attribute, value = operands

            message += format_diff(attribute, nil, value)
          when '+'
            attribute, value = operands

            message += format_diff(attribute, value, nil)
          else
            attribute, actual_value, expected_value = operands

            message += format_diff(attribute, expected_value, actual_value)
        end
      end

      message
    end

    private

    def format_diff(attribute, expected, actual)
      diff_description = ''
      diff_description += "#{attribute}\n"
      diff_description += "Expected: #{format_value(expected)}\n"
      diff_description += "Actual: #{format_value(actual)}\n\n"
      diff_description
    end

    def format_value(value)
      if value.kind_of?(String)
        "'#{value}'"
      else
        value
      end
    end

  end
end
