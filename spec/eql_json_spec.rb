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

  context "when comparing complicated objects" do

    let(:expected ) { {
        "a" => "aa",
        "b" => "bb",
        "c" => {
            "d" => 2,
            "e" => "ee",
            "f" => [{
                "g" => "gg",
                "h" => "hh",
            },
                {
                    "g" => "g1",
                    "h" => "h1",
                }
            ],
            "i" => {
                "j" => "jj",
                "k" => "kk",
                "l" => [],
                "m" => {
                    "n" => 1,
                    "o" => "oo",
                    "p" => {
                        "q" => "qq"
                    },
                    "r" => [],
                },
            },
            "s" => [
                {
                    "t" => 179,
                    "u" => "UU"
                }
            ]
        }
    } }

    let(:actual) { {
        "a" => "aa",
        "b" => "bb",
        "c" => {
            "d" => 3,
            "e" => "ee",
            "f" => [{
                "g" => "g1",
                "h" => "hh",
            },
                {
                    "g" => "g1",
                    "h" => "h1",
                    "h2" => "h2"
                }
            ],
            "i" => {
                "j" => "j2",
                "k" => "kk",
                "l" => [2],
                "m" => {
                    "o" => "oo",
                    "p" => {
                        "q" => "qq"
                    },
                    "r" => [],
                },
            },
            "s" => [
                {
                    "t" => 179,
                    "u" => "UU"
                }
            ]
        }
    } }

    it "then correctly reports the elements that have changed" do

      expect(actual).to eql(actual)

      expect(actual).to_not eql(expected)

      begin
        expect(actual).to eql_json(expected)
      rescue RSpec::Expectations::ExpectationNotMetError => e

        expect(e.message).to eql(error_message(expected, actual, {
          'c.d' => {
              expected: 2,
              actual: 3
          },
          'c.f[0].g' => {
              expected: "'gg'",
              actual: "'g1'"
          },
          'c.f[1].h2' => {
              expected: nil,
              actual: "'h2'"
          },
          'c.i.j' => {
              expected: "'jj'",
              actual: "'j2'"
          },
          'c.i.l[0]' => {
              expected: nil,
              actual: 2
          },
          'c.i.m.n' => {
              expected: 1,
              actual: nil
          }
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
