# Rollday

Rollday is a a gem to integrate with Faraday requests. It adds a default middleware for your projecrts Faraday client to send a rollbar for configurable response status codes.

It can be configured once for th eentire project, or customized per Faraday request


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rollday'
```

## Usage

### Initialization

Intialization should happen in `app/initializers/rollday.rb`. All options below are the current defaults unless stated
```ruby
Rollday.configure do |config|
  config.use_default_middleware! # [Not default option] set middleware for all Faraday requests (Faraday.get(...)). Caution when used with Default Client Middleware

  config.use_default_client_middleware! # [Not default option] set middleware for all Faraday instances. Caution when used with Default Middleware

  config.status_code_regex = /[45]\d\d$/ # If status code matches, will attempt to send a rollbar

  config.use_person_scope = true # Assign a person scope to the rollbar scope

  config.use_params_scope = true # Assign a params scope to the rollbar scope. Configured from Faraday params for request

  config.params_scope_sanitizer = [] # Array of Procs to sanitize params. Can remove params or call Rollbar::Scrubbers.scrub_value(*) to assign value

  config.use_query_scope = true # Assign the url queries to the scope

  config.params_query_sanitizer = [] # Array of Procs to sanitize query params. Can remove params or call Rollbar::Scrubbers.scrub_value(*) to assign value

  config.message = ->(status, phrase, body, path, domain) { "[#{status}]: #{domain} - #{path}" } # Message to set for the Rollbar item. Value can be a proc or a static message

  config.use_message_exception = true # When set to true, Exception will be used to establish a backtrace

  config.rollbar_level = ->(_status) { :warning } # Rollbar level can be configurable based on the status code
end
```

### Ex: Default Faraday Client

```ruby
# Rollday initializer
Rollday.configure do |config|
  config.use_default_middleware!
  config.status_code_regex = /[2345]\d\d$/
  config.message = -> (s, phrase, b, path, domain) { "[#{domain}] via #{path} returned #{status}" }
end

Farady.get("http://httpstat.us/207") # => 200 status code returned
# Will send a rollbar because Status code matches regex
```

### Ex: Default Faraday Instance

```ruby
# Rollday initializer
Rollday.configure do |config|
  config.use_default_client_middleware!
  config.message = -> (s, phrase, b, path, domain) { "[#{domain}] via #{path} returned #{status} using default client middleware" }
end
Farady.get("http://httpstat.us/500") # => 500 status code returned
# Rollbar will not get sent because `use_default_middleware!` is not set

client = Faraday.new(url: base_url)
client.get("404") # => 404 status code returned
# Will send a rollbar because Status code matches regex
```

### Ex: Custom Faraday Instance

```ruby
# Rollday initializer
Rollday.configure do |config|
  config.status_code_regex = /[2]\d\d$/
  config.message = -> (s, phrase, b, path, domain) { "[#{domain}] via #{path} returned #{status} using custom client middleware" }
end
Farady.get("http://httpstat.us/500") # => 500 status code returned
# Rollbar will not get sent because `use_default_middleware!` is not set

client = Faraday.new(url: base_url) do |conn|
  conn.use Rollday::MIDDLEWARE_NAME
end
client.get("209") # => 209 status code returned
# Will send a rollbar because Status code matches regex
```

### Use Caution
```ruby
# Rollday initializer
Rollday.configure do |config|
  # Do not do this!
  config.use_default_middleware!
  config.use_default_client_middleware!
end
```
Adding both the `use_default_middleware!` and the `use_default_client_middleware!` will cause double reporting of all default Faraday builders.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake rspec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment. Run `bundle exec rollday` to use
the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

1. Update the version number in [lib/rollday/version.rb]
2. Update [CHANGELOG.md]
3. Merge to the main branch. This will trigger an automatic build in CircleCI
   and push the new gem to the repo.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/matt-taylor/rollday.

