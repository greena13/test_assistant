require 'capybara/rspec'
require 'hashdiff'

module TestAssistant::Json
  # Backing class for the eql_json RSpec matcher. Used for matching Ruby representations
  # of JSON response bodies. Provides clear diff representations for simple and complex
  # or nested JSON objects, highlighting only the values that are different, and where
  # they are in the larger JSON object.
  #
  # Expected to be used as part of a RSpec test suite and with json_response.
  #
  # Implements the same interface as RSpec custom matcher classes
  #
  # @see TestAssistant::Json::Helpers#json_response
  # @see TestAssistant::Json::Helpers#eql_json
  class Expectation
    # Creates a new TestAssistant::Json::Expectation object.
    #
    # @see TestAssistant::Json::Helpers#eql_json
    #
    # @param expected the expected value that will be compared with the actual value
    # @return [TestAssistant::Json::Expectation] new expectation object
    def initialize(expected)
      @expected = expected
      @message = ''
      @reported_differences = {}
    end

    # Declares that RSpec should not attempt to diff the actual and expected values
    # to put in the failure message. This class takes care of diffing and presenting
    # the differences, itself.
    # @return [false] always returns false
    def diffable?
      false
    end

    # Whether the actual value and the expected value are considered equal.
    # @param actual value to be compared to the expected value for equality
    # @return [Boolean] whether actual is equal to expected
    def matches?(actual)
      @actual = actual
      @expected.eql?(@actual)
    end

    # Message to display to StdOut by RSpec if the equality check fails. Includes a
    # complete serialisation of the expected and actual values and is then followed
    # by a description of only the (possibly deeply nested) attributes that are
    # different
    # @return [String] message full failure message with explanation of why actual
    #   failed the equality check with expected
    def failure_message
      @message += "Expected: #{@expected}\n\n"
      @message += "Actual: #{@actual}\n\n"
      @message += "Differences\n\n"

      add_diff_to_message(@actual, @expected)

      @message
    end

    private

    # Adds diff descriptions to the failure message until the all the nodes of the
    # expected and actual values have been compared and all the differences (and the
    # paths to them) have been included. For Hashes and Arrays, it recursively calls
    # itself to compare all nodes and elements.
    #
    # @param actual_value current node of the actual value being compared to the
    #   corresponding node of the expected value
    # @param expected_value current node of the expected value being compared to
    #   the corresponding node of the actual value
    # @param [String] path path to the current nodes being compared,
    #   relative to the root full objects
    # @return void Diff descriptions are appended directly to message
    def add_diff_to_message(actual_value, expected_value, path = '')
      diffs_sorted_by_name = HashDiff
                        .diff(actual_value, expected_value)
                        .sort{|diff1, diff2| diff1[1] <=> diff2[1]}

      diffs_grouped_by_name =
        diffs_sorted_by_name.inject({}) do |memo, diff|
          operator, name, value = diff
          memo[name] ||= {}
          memo[name][operator] = value
          memo
        end

      diffs_grouped_by_name.each do |name, difference|

        missing_value = difference['-'] || value_at_path(actual_value, name)
        extra_value = difference['+'] || value_at_path(expected_value, name)
        different_value = difference['~']

        full_path = path.length > 0 ? "#{path}.#{name}" : name

        if non_empty_hash?(missing_value) && non_empty_hash?(extra_value)

          add_diff_to_message(missing_value, extra_value, full_path)

        elsif non_empty_array?(missing_value) && non_empty_array?(extra_value)

          [ missing_value.length, extra_value.length ].max.times do |i|
            add_diff_to_message(missing_value[i], extra_value[i], full_path)
          end

        else
          if difference.has_key?('~')
            append_to_message(full_path,
                get_diff(
                    full_path,
                    expected: value_at_path(expected_value, name),
                    actual: different_value
                )
            )
          else
            append_to_message(full_path,
                get_diff(
                  full_path,
                  expected: extra_value,
                  actual: missing_value
              )
            )
          end
        end

      end
    end

    def non_empty_hash?(target)
      target.kind_of?(Hash) && target.any?
    end

    def non_empty_array?(target)
      target.kind_of?(Array) && target.any?
    end

    def append_to_message(attribute, difference_description)
      unless already_reported_difference?(attribute)
        @message += difference_description
        @reported_differences[attribute] = true
      end
    end

    def already_reported_difference?(attribute)
      !!@reported_differences[attribute]
    end

    def value_at_path(target, attribute_path)
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

    def get_diff(attribute, options = {})
      diff_description = ''
      diff_description += "#{attribute}\n"
      diff_description += "Expected: #{format_value(options[:expected])}\n"
      diff_description + "Actual: #{format_value(options[:actual])}\n\n"
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
