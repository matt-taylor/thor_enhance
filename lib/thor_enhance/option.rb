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

      ::Thor::Option.include ThorEnhance::Option
    end

    def initialize(name, options = {})
      super

      thor_enhance_definitions(options)
    end

    def thor_enhance_definitions(options)
      ThorEnhance.configuration.option_enhance.each do |name, object|
        if options[name.to_sym].nil? && object[:required]
          raise RequiredOption, "#{@name} does not have required option #{name}. Please add it to the option"
        end

        value = options[name.to_sym]
        if value.nil? && object[:required] == false
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
