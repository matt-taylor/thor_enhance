# frozen_string_literal: true

require "thor"

module ThorEnhance
  module CommandMethod

    def self.thor_enhance_injection!
      return false unless ThorEnhance::Configuration.allow_changes?

      # This will dynamically define a class on the Thor module
      # This allows us to add convenience helpers per method
      ThorEnhance.configuration.command_method_enhance.each do |name, object|
        # This is how thor works -- at the class level using memoization
        # Interesting approach and it works because thor should boot before everything else -- and only boots once
        ClassMethods.define_method("#{name}") do |input|
          value = instance_variable_get("@#{name}")
          value ||= {}
          if @usage.nil?
            raise ArgumentError, "Usage is not set. Please ensure `#{name}` is defined after usage is set"
          end
          if object[:repeatable]
            value[@usage] ||= []
            value[@usage] << input
          else
            value[@usage] = input
          end

          instance_variable_set("@#{name}", value)
        end
      end

      ::Thor.include ThorEnhance::CommandMethod
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Call all things super for it (super in thor also calls super as well)
      # If the command exists, then add the initi
      def method_added(meth)
        super(meth)

        # Skip if the we should not be creating the command
        if command = all_commands[meth.to_s]
          ThorEnhance.configuration.command_method_enhance.each do |name, object|
            # When value is not required and not present, it will not exist. Rescue and return nil
            value = instance_variable_get("@#{name}")[meth.to_s] rescue nil
            command.send("#{name}=", value)
          end
        end
      end
    end
  end
end
