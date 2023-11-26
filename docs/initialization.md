# Initialize ThorEnhance

ThorEnhance requires initialization prior to your custom Thor classes loading.

## How to initialize

ThorEnhance provides several ways to enforce options on downstream classes.

### Preferred route
When creating the Thor Class, set `thor_enhance_allow!` at the top of the class. This will allow `ThorEnhance` to know that what class to allow and enforce enhancments for
```ruby
class Enhance < Thor
  thor_enhance_allow!
  ...
end
```

If you have methods are are not ready to abide by the enformence, No worries. Simple use the enable/disable wrappers.

```ruby
class Enhance < Thor
  thor_enhance_allow!

  disable_thor_enhance! do
    desc task1 # No enhancements are required
    def task1;end;

    enable_thor_enhance! do
      desc task2 # All enhancements are required
      def task2;end;
    end
  end

  desc task3 # All enhancements are required
  def task3;end;
end
```


### Alternate route
When initializing the `ThorEnhance` gem in the configuration, add the following code:
```ruby
ThorEnhance.configure do |c|
  ...
  c.allowed = :all
  ...
end
```

The above code will enforce all Thor classes have required ThorEnhanced enhancements.

**Caution**: Other gems that utilize thor like `Rake` `RSpec` `Rails` may fail on boot when utilizing the `:all` option. Use with caution



[Method Options](method_option.md)
[Command Options](command.md)

## Example

[Basic Example](../examples/basic_example.md)
[Basic Example with Subcommand](../examples/basic_example_with_subcommand.md)
