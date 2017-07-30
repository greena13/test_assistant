# TestAssistant

RSpec toolbox for writing and diagnosing Ruby on Rails tests, faster - especially emails and JSON APIs.

## Features

* Light-weight, scoped, lazily executed and composable tool-box, so you only include the features you want to use, when you want to use them with no unnecessary overhead
* JSON assertion that gives noise-free reports on complex nested structures, so you can find out exactly what has changed with your JSON API without having to manually diff large objects
* Expressive email assertions that let you succinctly describe when emails should and should not sent
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

## Email expectations

Test Assistant provides a declarative API for describing when emails should be sent and their characteristics.

### Setup

```ruby
TestAssistant.configure(config) do |ta_config|
  ta_config.include_email_helpers type: :request
end
```

### Clearing emails

Emails can be cleared at any point by calling `clear_emails` in your tests. This is helpful when you are testing a user workflow that may trigger multiple emails.

Emails are automatically cleared between each request spec.

### Email receiver address

It's possible to assert an email was sent to one or more or more addresses using the following format:

```ruby
expect(email).to have_been_sent.to('user@email.com')
```

### Email sender address

Similarly, you can assert an email was sent from an address:

```ruby
expect(email).to have_been_sent.from('user@email.com')
```

### Email subject

You can assert an email's subject:

```ruby
expect(email).to have_been_sent.with_subject('Welcome!')
```


### Email body

You can assert the body of an email by text:

```ruby
expect(email).to have_been_sent.with_text('Welcome, user@email.com')
```

Or using a selector on the email's HTML:

```ruby
expect(email).to have_been_sent.with_selector('#password')
```

Or look for links:

```ruby
expect(email).to have_been_sent.with_link('www.site.com/onboarding/1')
```

Or images:

```ruby
expect(email).to have_been_sent.with_image('www.site.com/assets/images/welcome.png')
```

### Chaining assertions

You can chain any combination of the above that you want for ultra specific assertions:


```ruby
expect(email).to have_been_sent
                  .to('user@email.com')
                  .from('admin@site.com')
                  .with_subject('Welcome!')
                  .with_text('Welcome, user@email.com')
                  .with_selector('#password').and('#username')
                  .with_link('www.site.com/onboarding/1')
                  .with_image('www.site.com/assets/images/welcome.png')

```

You can also chain multiple assertions of the the same type with the `and` method:

```ruby
expect(email).to have_been_sent
                    .with_text('Welcome, user@email.com').and('Thanks for signing up')
```

### Asserting emails are NOT sent

The `have_sent_email` assertion works with the negative case as well:

```ruby
expect(email).to_not have_been_sent.with_text('Secret token')
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

## Inspirations

* [CapybaraEmail](https://github.com/DockYard/capybara-email)
