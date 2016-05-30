# TestAssistant

A collection of testing tools, hacks, and utilities for writing and fixing tests faster

## Stability

TestAssistant is in its infancy and should be considered unstable. The API and behaviour is likely to change. 


## Installation

Add this line to your application's Gemfile:

    group :test do
      gem 'test_assistant'
    end

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install test_assistant

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

### Rendering a response context when a test fails

Test assistant can automatically render the server response in your browser when a test fails and you have applied a nominated tag. 

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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/test_assistant/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
