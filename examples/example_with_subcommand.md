```ruby
# thor_enhance_config.rb

require "thor_enhance"

ThorEnhance.configure do |c|
  # Adds `classify` method to the option class
  # Value of classify must be one of the enums
  # It is not a required field on every method
  c.add_option_enhance :classify, allowed_klasses: [Symbol], required: false

  # Adds `publish` method to the option
  # Value of classify must be one of the enums
  # It is a required field on every option
  c.add_option_enhance "publish", allowed_klasses: [TrueClass, FalseClass], required: true

  # Adds `example` method to the command
  # Value can be anything and is a repeatable command
  c.add_command_method_enhance :example, repeatable: true
end
```

```ruby
# thor_cli.rb

require "rubygems"
require "bundler/setup"
require "thor_enhance_config"

class ThorEnhancement < Thor
  thor_enhance_allow!

  dec "test", "Testing method"
  example "thor_cli.rb test --value 'This is rad'"
  example "thor_cli.rb test"
  method_option :value, type: :string, publish: true
  def test
    command = ThorEnhance::Tree.tree(base: self.class)["test"].command
    # example was set as `repeatable` so it gets returned as an array
    command.example.each { puts _1 }

    command.options[:value].publish == true
    command.options[:value].classify == nil
  end

  class SubCommand < Thor
    thor_enhance_allow!

    desc "sub_command", "Command for SubCommand"
    example "bin/thor sub_command innard -t something -s better"
    example "bin/thor sub_command innard -s better"
    example "bin/thor sub_command innard"

    method_option :t, type: :string, classify: :allowed, publish: true
    method_option :s, type: :string, classify: :erase, publish: false
    def sub_command
      parent = ThorEnhance::Tree.tree(base: self.class)["sub"]
      parent.example.each { puts _1 } # 1 example

      command = parent.children["sub_command"].command
      command.children? == false

      command.example.each { puts _1 } # 3 examples

      command.options[:t].publish == true
      command.options[:t].classify == :allowed
    end
  end

  desc "sub", "Submodule command line"
  example "bin/thor sub ***"
  subcommand "sub", SubCommand
end

ThorEnhancement.start
```
