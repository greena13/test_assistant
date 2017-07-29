require 'capybara/rspec'
require 'hashdiff'

module TestAssistant::Json
  class Expectation
    def initialize(expected)
      @expected = expected
      @message = ''
      @reported_differences = {}
    end

    def diffable?
      false
    end

    def matches?(actual)
      @actual = actual
      @expected.eql?(@actual)
    end

    def failure_message
      @message += "Expected: #{@expected}\n\n"
      @message += "Actual: #{@actual}\n\n"
      @message += "Differences\n\n"

      add_diff_to_message(@actual, @expected)

      @message
    end

    private

    def add_diff_to_message(original_actual, original_expected, parent_prefix = '')
      differences = HashDiff
                        .diff(original_actual, original_expected)
                        .sort{|diff1, diff2| diff1[1] <=> diff2[1]}

      grouped_differences =
          differences.inject({}) do |memo, diff|
            operator, name, value = diff
            memo[name] ||= {}
            memo[name][operator] = value
            memo
          end

      grouped_differences.each do |name, difference|
        removed_value = difference['-']
        added_value = difference['+']
        swapped_value = difference['~']

        full_name = parent_prefix.length > 0 ? "#{parent_prefix}.#{name}" : name

        if non_empty_hash?(removed_value) && non_empty_hash?(added_value)
          add_diff_to_message(removed_value, added_value, full_name)

        elsif non_empty_array?(removed_value) && non_empty_array?(added_value)

          [removed_value.length, added_value.length].max.times do |i|
            add_diff_to_message(removed_value[i], added_value[i], full_name)
          end
        else
          if difference.has_key?('~')
            add_diff_description(full_name,
                format_diff(
                    full_name,
                    attribute_value(original_expected, name),
                    swapped_value
                )
            )
          else
            add_diff_description(full_name,
                format_diff(
                  full_name,
                  added_value || attribute_value(original_expected, name),
                  removed_value || attribute_value(original_actual, name)
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
