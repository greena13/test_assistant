require './lib/test_assistant/json/helpers'

RSpec.describe "eql_json" do
  include TestAssistant::Json::Helpers

  context "when comparing strings" do
    let(:expected) { 'a' }
    let(:actual) { 'b' }

    it "then correctly reports any differences" do

      expect(actual).to eql_json(actual)

      expect(actual).to_not eql(expected)

      expect {
        expect(actual).to eql_json(expected)
      }.to raise_error.with_message(error_message(expected, actual, {
          '' => {
              expected: "'#{expected}'",
              actual: "'#{actual}'"
          }
      }))
    end
  end

  context "when comparing integers" do
    let(:expected) { 2 }
    let(:actual) { 1 }

    it "then correctly reports any differences" do

      expect(actual).to eql_json(actual)

      expect(actual).to_not eql(expected)

      expect {
        expect(actual).to eql_json(expected)
      }.to raise_error.with_message(error_message(expected, actual, {
          '' => {
              expected: expected,
              actual: actual
          }
      }))
    end
  end

  context "when comparing nil" do
    let(:expected) { 2 }
    let(:actual) { nil }

    it "then correctly reports any differences" do
      expect(actual).to eql_json(actual)

      expect(actual).to_not eql(expected)

      expect {
        expect(actual).to eql_json(expected)
      }.to raise_error.with_message(error_message(expected, actual, {
          '' => {
              expected: expected,
              actual: actual
          }
      }))

    end

  end

  context "when comparing arrays" do
    let(:expected) { [ 1, 3, 4, 5 ] }
    let(:actual) { [ 1, 2, 3 ] }

    it "then correctly reports the elements that have changed" do

      expect(actual).to eql(actual)

      expect(actual).to_not eql(expected)

      begin
        expect(actual).to eql_json(expected)
      rescue RSpec::Expectations::ExpectationNotMetError => e

        expect(e.message).to eql(error_message(expected, actual, {

          '[1]' => {
              expected: 3,
              actual: 2
          },
          '[2]' => {
              expected: 4,
              actual: 3
          },
          '[3]' => {
              expected: 5,
              actual: ''
          }

        }))

      end

    end

  end

  context "when comparing arrays of objects" do
    let(:expected) {
      {
          'alpha' => 'alpha',
          'beta' => [ 1, 2, 3],
          'gamma' => [
              { 'i' => 'a', 'j' => 'b' },
              { 'i' => 'c', 'j' => 'd' },
              { 'i' => 'e', 'j' => 'f' },
          ]
      }
    }

    let(:actual) {
      {
          'alpha' => 'alpha',
          'beta' => [ 1, 2, 3],
          'gamma' => [
              { 'j' => 'b' },
              { 'i' => 'c', 'j' => 'D' },
              { 'i' => 'e', 'j' => 'f', 'k' => 'k' },
          ]
      }
    }

    it "then correctly reports the elements that have changed" do

      expect(actual).to eql(actual)

      expect(actual).to_not eql(expected)

      begin
        expect(actual).to eql_json(expected)
      rescue RSpec::Expectations::ExpectationNotMetError => e

        expect(e.message).to eql(error_message(expected, actual, {

          'gamma[0].i' => {
              expected: "'a'",
              actual: ''
          },
          'gamma[1].j' => {
              expected: "'d'",
              actual: "'D'"
          },
          'gamma[2].k' => {
              expected: '',
              actual: "'k'"
          }

        }))

      end

    end

  end

  context "when comparing objects" do
    let(:expected) { {
        'a' => 'a',
        'c' => 'd',
        'e' => 'e'
    } }

    let(:actual) { {
        'a' => 'a',
        'b' => 'b',
        'c' => 'c'
    } }

    it "then correctly reports the elements that have changed" do

      expect(actual).to eql(actual)

      expect(actual).to_not eql(expected)

      begin
        expect(actual).to eql_json(expected)
      rescue RSpec::Expectations::ExpectationNotMetError => e

        expect(e.message).to eql(error_message(expected, actual, {

          'b' => {
              expected: '',
              actual: "'b'"
          },
          'c' => {
              expected: "'d'",
              actual: "'c'"
          },
          'e' => {
              expected: "'e'",
              actual: ''
          }

        }))

      end

    end

  end

  context "when comparing nested objects" do
    let(:actual) { {
        'a' => 'a',
        'b' => {
            'b' => 'b'
        },
        'c' => {
            'd' => 'd',
            'e' => 'e',
            'f' => {
                'g' => 'g'
            },
            'h' => [1,2,3]
        },
        'i' => {
            'j' => 'j',
            'k' => 'k'
        }
    } }

    let(:expected ) { {
        'a' => 'a',
        'c' => {
            'e' => 'e2',
            'f' => {
                'g2' => 'g2'
            },
            'h' => [1,2,4]
        },
        'i' => {
            'j' => 'j',
        }
    } }

    it "then correctly reports the elements that have changed" do

      expect(actual).to eql(actual)

      expect(actual).to_not eql(expected)

      begin
        expect(actual).to eql_json(expected)
      rescue RSpec::Expectations::ExpectationNotMetError => e

        expect(e.message).to eql(error_message(expected, actual, {

          'b' => {
              expected: '',
              actual: '{"b"=>"b"}'
          },
          'c.d' => {
              expected: '',
              actual: "'d'"
          },
          'c.e' => {
              expected: "'e2'",
              actual: "'e'"
          },
          'c.f.g' => {
              expected: '',
              actual: "'g'"
          },
          'c.f.g2' => {
              expected: "'g2'",
              actual: ''
          },
          'c.h[2]' => {
              expected: '4',
              actual: '3'
          },
          'i.k' => {
              expected: '',
              actual: "'k'"
          },


        }))

      end

    end

  end


  private

  def error_message(expected, actual, differences)
    message_lines = [
        "Expected: #{expected}\n\n",
        "Actual: #{actual}\n\n",
        "Differences\n\n"
    ]

    differences.each do |attribute_name, difference|
      message_lines.push("#{attribute_name}\n")
      message_lines.push("Expected: #{difference[:expected]}\n")
      message_lines.push("Actual: #{difference[:actual]}\n\n")
    end


    message_lines.join
  end
end
