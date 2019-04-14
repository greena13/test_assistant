<p align="center">
  <img src="https://svgshare.com/i/CRk.svg" width="200px" /><br/>
  <h2 align="center">TestAssistant</h2>
</p>

RSpec toolbox for writing and diagnosing Ruby on Rails tests, faster.

## Features

* Light-weight, scoped, lazily executed and composable tool-box, so you only include the features you want to use, when you want to use them with no unnecessary overhead
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

1. Fork it ( https://github.com/greena13/test_assistant/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
