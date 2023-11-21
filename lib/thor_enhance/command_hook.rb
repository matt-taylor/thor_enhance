# frozen_string_literal: true

require "thor"

module ThorEnhance
  module CommandHook
    def run(instance, args = [])
      raw_args = instance.instance_variable_get(:@_initializer)[1]
      ThorEnhance::Configuration::HOOKERS.each do |hook|
        object = ThorEnhance.configuration.option_enhance[hook]
        # Iterate the options list based on each hook type
        instance.options.each do |name, given_value|
          option = options[name.to_s] || options[name.to_sym]
          next if option.nil?

          # If the hook exists on the method option, retreive it
          # if not, move on
          proclamation = option.send(hook)
          next if proclamation.nil?

          # if input tags is included in raw args, the user inputted the value
          # hooks should only get called if the value was inputted
          input_tags = [option.switch_name] + option.aliases
          next unless input_tags.any? { raw_args.include?(_1) }

          proc_value = proclamation.(given_value)

          case object[:behavior]
          when :raise
            raise ThorEnhance::OptionDeprecated, "Passing value for option #{option.switch_name} is deprecated. Provided `#{given_value}`. #{proc_value}"
          when :warn
            Kernel.warn("WARNING: Provided `#{given_value}` for option #{option.switch_name}. #{proc_value}")
          end
        end
      end

      super
    end
  end
end
