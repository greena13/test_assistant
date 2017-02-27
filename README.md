# TestAssistant

A collection of testing tools and utilities for writing and fixing tests faster

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

## JSON expectations

RSpec's failed equality reports are often extremely difficult to interpret when dealing with complicated JSON objects. A minor difference, deeply nested in arrays and objects can take a long time to locate because RSpec dumps the entire object in the failure message.
 

When enabled, Test Assistant provides a method `json_response` that automatically parses the last response object as json and a custom assertion `eql_json` that reports failed equality of complicated json objects in a format that is much clearer. The full `expected` and `actual` values are still reported, but below them Test Assistant prints only the paths to the failed nested values and their differences, removing the need to manually compare the two complete objects to find what is different. 

```ruby
TestAssistant.configure(config) do |ta_config|
  ta_config.include_json_helpers type: :request
end
```

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


```ruby
TestAssistant.configure(config) do |ta_config|
  ta_config.include_email_helpers type: :request
end
```

```ruby
RSpec.describe 'making some valid request', type: :request do
  context 'some important context' do
    it 'should send an email' do
      expect(email).to have_been_sent
                          .to('user@email.com')
                          .from('admin@site.com')
                          .with_subject('Welcome!')
                          .with_text('Welcome, user@email.com').and('Thanks for signing up')
                          .with_selector('#password').and('#username')
                          .with_link('www.site.com/onboarding/1')
                          .with_image('www.site.com/assets/images/welcome.png')
                          
      clear_emails
      
      # further actions
      
      expect(email).to have_been_sent.to('user@email.com')
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

## Inspirations

* [CapybaraEmail](https://github.com/DockYard/capybara-email)
