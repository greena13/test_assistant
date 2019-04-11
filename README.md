# TestAssistant

RSpec toolbox for writing and diagnosing Ruby on Rails tests, faster.

## Features

* Light-weight, scoped, lazily executed and composable tool-box, so you only include the features you want to use, when you want to use them with no unnecessary overhead
* JSON assertion that gives noise-free reports on complex nested structures, so you can find out exactly what has changed with your JSON API without having to manually diff large objects
* Automatic reporting of the context around failing tests, so you don't have to re-run them with additional logging or a debugger

## Installation

Add this line to your application's Gemfile:

    group :test do
      gem 'test_assistant'
    end

And then execute:

    $ bundle

## Usage

Test assistant requires access to the RSpec configuration object, so add the following to either `rails_helper.rb` or `spec_helper.rb`:

```ruby
RSpec.configure do |config|
  # other rspec configuration

  TestAssistant.configure(config) do |ta_config|
    # test assistant configuration here
  end
end
```

## JSON expectations

Test Assistant lets you include helpers in your controller and request specs to get succinct declarative methods for defining the expected results for JSON responses.

### Setup

```ruby
TestAssistant.configure(config) do |ta_config|
  ta_config.include_json_helpers type: :request
end
```

### Asserting JSON responses

Among the helpers provided are `json_response`, which automatically parses the last response object as json, and a custom assertion `eql_json` that reports failures in a format that is much clearer than anything provided by RSpec.

The full `expected` and `actual` values are still reported, but below is a separate report that only includes the paths to the failed nested values and their differences, removing the need to manually compare the two complete objects to find the difference.

```ruby
RSpec.describe 'making some valid request', type: :request do
  context 'some important context' do
    it 'should return some complicated JSON' do

      perform_request

      expect(json_response).to eql_json([
        {
            "a" => [
                1, 2, 3
           ],
           "c" => { "d" => "d'"}
        },
        {
            "b" => [
                1, 2, 3
           ],
           "c" => { "d" => "d'"}
        }
      ])
    end
  end
end
```

## Failure Reporting

### Rendering a response context when a test fails

Test Assistant can automatically render the server response in your browser when a test fails and you have applied a nominated tag.

```ruby
TestAssistant.configure(config) do |ta_config|
  ta_config.render_failed_responses tag: :focus, type: :request
end
```

```ruby
RSpec.describe 'making some valid request', type: :request do
  context 'some important context' do
    it 'should return a correct result', focus: true do
      # failing assertions
    end
  end
end
```

### Invoking a debugger when a test fails

It's possible to invoke a debugger (`pry` is default, but fallback is to `byebug` and then `debugger`) if a test fails. This gives you access to some of the scope that the failing test ran in, allowing you to inspect objects and test variations of the failing assertion.

The `debug_failed_responses` accepts a the following options:

* `tag: :<tag_name>` (default is `:debugger`)
* `type: :<spec_type>` (default: nil - matches all test types) options.

```ruby
TestAssistant.configure(config) do |ta_config|
    ta_config.include_json_helpers type: :request

    ta_config.debug_failed_responses tag: :debugger
  end
```

```ruby
RSpec.describe 'making some valid request', type: :request do
  context 'some important context' do
    it 'should return a correct result', debugger: true do
      # failing assertions
    end
  end
end
```

## Test suite

TestAssistant comes with close to complete test coverage. You can run the test suite as follows:

```bash
rspec
```

## Contributing

1. Fork it ( https://github.com/greena13/test_assistant/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
