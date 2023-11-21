# Hooks:

Hooks allow you to slowly deprecate options over time. There are three basic Hooks available on every method_option

## Arguments:
Both `deprecate` and `hook` are expected to be a `proc`. The input arguments will be `input, options`

### Argument: Input
The `input` argument is the first argument. It is the value that the user inputted. When there is no user input, the hook will not run.

### Argument: Option
The `option` argument is the second argument. It is the `Thor::Option` struct for that existing method. The instance will have all ThorEnhance methods available.

## Deprecate:
The `deprecate` hook is available on every `method_option`. It expects a `Proc` class. The returned value from the proc is expected as either an Hash or a String.

This hook should be used when you want to either immediately depreacte a method or over time deprecate a command while migrating to a new command. The decision to raise or warn is dynamic in real time.

### When returned an String
If the method option is provided, it will raise `ThorEnhance::OptionDeprecated` every time

### When returned a Hash
**hash[:raise]**: Expected a boolean value on weather to raise or warn. When true, it will raise `ThorEnhance::OptionDeprecated`. When false it will send WARNING to console
**hash[:warn]**: Console message used when `:raise` is false. Does not output when `:raise` is true
**hash[:msg]**: Message for both raise and warn. This should a short message on how to migrate to new command or syntax

```ruby
# When provided `--value1 "string"`:
# This will raise `ThorEnhance::OptionDeprecated` with a message that looks like:
# Passing value for option --value1 is deprecated. Provided `string`. Please migrate to `--value4`
method_option :value1, type: :string, deprecate: ->(input, option) { "Please migrate to `--value4`" }

# When provided `--value2 "string"` and deprecated criteria is not met:
# This will send a WARNING message to the console. It will resemble:
# Passing value for option --value1 is deprecated. Provided `string`. Please migrate to `--value4`
method_option :value2, type: :string, deprecate: ->(input, option) { { raise: Date.today > Date.today, warn: "This option will deprecate after #{Date.today}", msg: "Please migrate to --value4"} }

# When provided `--value3 "string"` and deprecated criteria is:
# This will raise `ThorEnhance::OptionDeprecated` with a message that looks like:
# Passing value for option --value3 is deprecated. Provided `string`. Please migrate to `--value4`
method_option :value3, type: :string, deprecate: ->(input, option) { { raise: true, warn: "This option will deprecate after #{Date.today}", msg: "Please migrate to --value4"} }
```

## Hook
The `hook` hook is available on every `method_option`. It expects a `Proc` class. No return value is expected. When the input is provided, custom code can get executed

```ruby
# When provided `--value1 "string"`:
# This will raise `ThorEnhance::OptionDeprecated` with a message that looks like:
# Passing value for option --value1 is deprecated. Provided `string`. Please migrate to `--value4`
method_option :value1, type: :string, hook: ->(input, option) { Kernel.puts "#{input} is a good choice for #{option.name}" }
```

---

# Examples

For examples, [please navigate here](../examples/hooks.md)

