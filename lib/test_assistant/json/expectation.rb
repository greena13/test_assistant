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
      @message = ''
      @reported_differences = {}

      @actual = actual
      @expected.eql?(@actual)
    end

    def failure_message
      @message += "Expected: #{@expected}\n\n"
      @message += "Actual: #{@actual}\n\n"
      @message += "Differences\n\n"

      differences = HashDiff.diff(@actual, @expected)

      differences.each do |difference|
        operator, *operands = difference

        case operator
          when '-'
            attribute, value = operands

            expected_value = attribute_value(@expected, attribute)
            add_diff_description(attribute, format_diff(attribute, expected_value, value))

          when '+'
            attribute, value = operands

            actual_value = attribute_value(@actual, attribute)

            add_diff_description(attribute, format_diff(attribute, value, actual_value))

          else
            attribute, actual_value, expected_value = operands

            add_diff_description(attribute, format_diff(attribute, expected_value, actual_value))
        end
      end

      @message
    end

    private

    def add_diff_description(attribute, difference_description)
      unless already_reported_difference?(attribute)
        @message += difference_description
        @reported_differences[attribute] = true
      end
    end

    def already_reported_difference?(attribute)
      !!@reported_differences[attribute]
    end

    def attribute_value(target, attribute_path)
      keys = attribute_path.split(/\[|\]|\./)

      keys = keys.map do |key|
        if key.to_i == 0 && key != '0'
          key
        else
          key.to_i
        end
      end

      result = target

      keys.each do |key|
        unless key == ''
          result = result[key]
        end
      end

      result
    end

    def format_diff(attribute, expected, actual)
      diff_description = ''
      diff_description += "#{attribute}\n"
      diff_description += "Expected: #{format_value(expected)}\n"
      diff_description += "Actual: #{format_value(actual)}\n\n"
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
