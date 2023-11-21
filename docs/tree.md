# ThorEnhance::Tree

The thor tree is a powerful tool to do introspection on all Thor commands within a repo.

## How to use:

MyTestClass definitiona can be found in [spec_helper.rb](../spec/spec_helper.rb)

```ruby
require "thor_enhance"

tree = ThorEnhance::Tree.tree(base: MyTestClass)

# View all commands on parent tree:
tree.children.map(&:command)

# View all commands including subcommands

def iterate_base(base:)
  tree.map do |name, object|
    if object.children?
      iterate_base(base: object)
    else
      object.command
    end
  end.flatten
end

iterate_base(base: tree)

# View specific command
command = tree["test_meth"].command

# View specific sub command
sub_command_innard = tree["sub"].children["innard"].command

# View Options on specific command
command.options

# View specific Option on specific command
sub_command_innard.options[:t]
```
