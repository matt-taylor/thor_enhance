# Hook Examples

For more information on how to use hooks, [view documentation here](../docs/hooks.md)

```ruby
# thor_enhance_config.rb

require "thor_enhance"

ThorEnhance.configure do |c|
  # Adds `classify` method to the option class
  # Value of classify must be one of the enums
  # It is not a required field on every method
  c.add_option_enhance "classify", enums: [:allowed, :future, :existing], required: false

  # Adds `publish` method to the option
  # Value of classify must be one of the enums
  # It is a required field on every option
  c.add_option_enhance :publish, enums: [true, false], required: true

  # Adds `example` method to the command
  # Value can be anything and is a repeatable command
  c.add_command_method_enhance "example", repeatable: true
end
```

```ruby
# thor_cli.rb

require "rubygems"
require "bundler/setup"
require "thor_enhance_config"

VERSION = Gem::Version.new("1.2.3")
MAX_VERSION = Gem::Version.new("2.0.0")

class ThorEnhancement < Thor
  thor_enhance_allow!
  dec "test", "Testing method"
  example "thor_cli.rb test --value 'This is rad'"
  example "thor_cli.rb test"
  method_option :value, type: :string, publish: true, deprecate: ->(input, option) { { raise: VERSION > MAX_VERSION, warn: "This option will deprecate with version #{MAX_VERSION}", msg: "Please migrate to --value4"} }

  # Deprecate hook
  method_option :option, type: :string, publish: false,
  method_option :test, type: :string, publish: false,
  def test
    command = ThorEnhance::Tree.tree(base: self.class)["test"].command
    # example was set as `repeatable` so it gets returned as an array
    command.example.each { puts _1 }

    command.options[:value].publish == true
    command.options[:value].classify == nil
  end
end

ThorEnhancement.start
```
