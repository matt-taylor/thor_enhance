# frozen_string_literal: true

require "thor"

module ThorEnhance
  module Option
    def self.thor_enhance_injection!
      return false unless ThorEnhance::Configuration.allow_changes?

      # Create getter method for the enhance instance variable
      ThorEnhance.configuration.option_enhance.each do |name, object|
        define_method(name) { instance_variable_get("@#{name}") }
      end
    end

    # Monkey patched initializer
    # Thor Option initializer only takes (name, options) as arguments
    # Thor::Option.new is only called from `build_option` which gets monkey patched in thor_enhance/base
    def initialize(name, options = {}, klass = nil)
      super(name, options)

      thor_enhance_definitions(options, klass)
    end

    def thor_enhance_definitions(options, klass)
      return nil unless ThorEnhance.configuration.allowed?(klass)

      ThorEnhance.configuration.option_enhance.each do |name, object|
        # When disabled, we do not do the required check, if present, it is still required to be a valid option otherwise
        unless ::Thor.__thor_enhance_definition == ThorEnhance::CommandMethod::ClassMethods::THOR_ENHANCE_DISABLE
          if options[name.to_sym].nil? && object[:required]
            raise RequiredOption, "#{@name} does not have required option #{name}. Please add it to the option"
          end
        end

        value = options[name.to_sym]
        if value.nil? # This can be nil here because we have already done a required check
          # no op when it is nil and not required
        elsif !object[:enums].nil?
          unless object[:enums].include?(value)
            raise ValidationFailed, "#{@name} recieved option #{name} with incorrect enum. Received: [#{value}]. Expected: [#{object[:enums]}]"
          end
        elsif !object[:allowed_klasses].nil?
          unless object[:allowed_klasses].include?(value.class)
            raise ValidationFailed, "#{@name} recieved option #{name} with incorrect class type. Received: [#{value.class}]. Expected: [#{object[:allowed_klasses]}]"
          end
        end

        instance_variable_set("@#{name}", value)
      end
    end
  end
end
