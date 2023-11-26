# Method Option Injection

Method option injection allows you to easily add additional flags to the `method_option` for commands. You can set them as required for every option. You can even set allowable values or allowable classes

## When to use:
This should be used when you want to enrich your command data. This data can then be retrieved by using the [ThorEnhance::Tree](tree.md) class.

## How to use

Additional configuration is needed prior to loading the your Thor instance

```ruby
# thor_enhance_config.rb
ThorEnhance.configure do |c|
  # Adds `classify` method to the option class
  # Value of classify must be one of the enums
  # It is not a required field on every method
  c.add_option_enhance "classify", allowed_klasses: [String, Symbol, NilClass], required: false

  # Adds `publish` method to the option
  # Value of classify must be one of the enums
  # It is a required field on every option
  c.add_option_enhance :publish, enums: [true, false], required: true

  # Adds `avoid method to the option
  # Value is not restricted to any type or enum
  # Not a required field
  c.add_option_enhance :avoid
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

# Examples:

[Basic Example](../examples/basic_example.md)
[Basic Example with Subcommand](../examples/basic_example_with_subcommand.md)
