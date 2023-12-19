# ThorEnhance

`ThorEnhance` enhances thor's capabiltiies. It allows customizable method options and task options.

Additionally it provides hooks into each method option that allows deprecation dynamically.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thor_enhance'
```

## Usage

### Hooks
Hooks allow you to deprecate, warn, or do some other custimizable action when a user calls thor with the specific option

[Hook documentation](docs/hooks.md)
[Hook examples](examples/hooks.md)

### Method option Injection
Method option injection allows you to enhance specific commands. When used inconjunction with [ThorEnhance::Tree](docs/tree.md), the added fields to the method options are avaialable in your code with ease.

[Method option documentation](docs/method_option.md)


### Command option Injection
Command option injection is very powerful. This allows add low level documentation in line with the actual code.

[Command option documentation](docs/command.md)

### Automatic ReadMe Generation
The beauty of ThorEnhance is that it forces all your documentation to live with the code. As your code changes, the documentation naturally changes with it.

ThorEnhance can automatically generate your code bases Readme for you.

[Autogenerate Readme](docs/autogenerate/Readme.md)


### Initialization

[Refere to documentation](docs/initialization.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/matt-taylor/thor_enhance.

