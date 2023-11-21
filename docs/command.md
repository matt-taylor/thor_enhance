# Command Method Injection

Command Method injection allows you to easily enrich Thor Commands with additional data.

## When to use:
This should be used when you want to enrich your command data. This data can then be retrieved by using the [ThorEnhance::Tree](tree.md) class.

## How to use

Additional configuration is needed prior to loading the your Thor instance

```ruby
# thor_enhance_config.rb
ThorEnhance.configure do |c|
  # Adds `example` method to the command
  # Value can be anything and is a repeatable command
  c.add_command_method_enhance "example", repeatable: true

  # Adds `validate` method to the command
  # Value must be one of :some or :thing
  c.add_command_method_enhance "validate", enum: [:some, :thing]

  # Adds `enhace` method to the command
  # Value must be of type CustomClass
  # It is repeatble and required
  c.add_command_method_enhance "enhance", allowed_klasses: [CustomClass], repeatable: true, required: true
end
```
The `add_option_enhance` takes the name as argument 1 followed by options.

The available options are:

**enums**:
- When provided, the value of the `name` must be a value in the `enums` array
EX: `publish: true` succeeds. `publish: :fail` fails.
- Default: `nil`

**allowed_klasses**
- When provided, this is expected to be an array of class types the value can be.
- Default: `nil`

**required**
- When flag is set to true, this option will be required on all `method_option` immediately. An error is raised if validation fails
- Default: `false`

**repeatable**
- When flag is set to true, this option will allow the same command to reference the method multiple times. The value will be retreable as an Array from [ThorEnhance::Tree](tree.md) class.
- Default: `false`

# Examples:

[Basic Example](../examples/basic_example.md)
[Basic Example with Subcommand](../examples/basic_example_with_subcommand.md)

