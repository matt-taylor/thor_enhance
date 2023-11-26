# frozen_string_literal: true

require "thor"

module ThorEnhance
  module CommandMethod

    def self.thor_enhance_injection!
      return false unless ThorEnhance::Configuration.allow_changes?

      # This will dynamically define class metohds on the Thor Base class
      # This allows us to add convenience helpers per method
      # Allows us to add inline helper class functions for each desc task
      ThorEnhance.configuration.command_method_enhance.each do |name, object|
        # Define a new method based on the name of each enhanced command method
        # Method takes care all validation except requirment -- Requirement is done during command initialization
        ClassMethods.define_method("#{name}") do |input|
          return nil unless ThorEnhance.configuration.allowed?(self)

          value = instance_variable_get("@#{name}")
          value ||= {}
          # Usage is nil when the `desc` has not been defined yet -- Under normal circumstance this will never happen
          if @usage.nil?
            raise ArgumentError, "Usage is not set. Please ensure `#{name}` is defined after usage is set"
          end

          # Required check gets done on command initialization (defined below in ClassMethods)
          if input.nil?
            # no op when it is nil
          elsif !object[:enums].nil?
            unless object[:enums].include?(input)
              raise ValidationFailed, "#{@usage} recieved command method `#{name}` with incorrect enum. Received: [#{input}]. Expected: [#{object[:enums]}]"
            end
          elsif !object[:allowed_klasses].nil?
            unless object[:allowed_klasses].include?(value.class)
              raise ValidationFailed, "#{@usage} recieved command method `#{name}` with incorrect class type. Received: [#{input.class}]. Expected: #{object[:allowed_klasses]}"
            end
          end

          if object[:repeatable]
            value[@usage] ||= []
            value[@usage] << input
          else
            if value[@usage]
              raise ValidationFailed, "#{@usage} recieved command method `#{name}` with repeated invocations of " \
                "`#{name}`. Please remove the secondary invocation. Or set `#{name}` as a repeatable command method"
            end

            value[@usage] = input
          end

          instance_variable_set("@#{name}", value)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      THOR_ENHANCE_ENABLE = :enable
      THOR_ENHANCE_DISABLE = :disable

      def disable_thor_enhance!(&block)
        __thor_enhance_access(type: THOR_ENHANCE_DISABLE, &block)
      end

      def enable_thor_enhance!(&block)
        __thor_enhance_access(type: THOR_ENHANCE_ENABLE, &block)
      end

      # Call all things super for it (super in thor also calls super as well)
      # If the command exists, then set the instance variable
      def method_added(meth)
        value = super(meth)

        # Skip if the command does not exist -- Super creates the command
        if command = all_commands[meth.to_s]

          if ThorEnhance.configuration.allowed?(self)
            ThorEnhance.configuration.command_method_enhance.each do |name, object|

              instance_variable = instance_variable_get("@#{name}")
              # instance variable was correctly assigned and exists as a hash
              if Hash === instance_variable
                # Expected key exists in the hash
                # This key already passed validation for type and enum
                # Set it and move on
                if instance_variable.key?(meth.to_s)
                  value = instance_variable[meth.to_s]
                  command.send("#{name}=", value)
                  next
                end
              end

              # At this point, the key command method was never invoked on for the `name` thor task
              # The value is nil/unset

              # If we have disabled required operations, go ahead and skip this
              next if ::Thor.__thor_enhance_definition == ThorEnhance::CommandMethod::ClassMethods::THOR_ENHANCE_DISABLE

              # Skip if the expected command method was not required
              next unless object[:required]

              # Skip if the method is part of the ignore list
              next if ThorEnhance::Tree.ignore_commands.include?(meth.to_s)

              # At this point, the command method is missing, we are not in disable mode, and the command method was required
              # raise all hell
              raise ThorEnhance::RequiredOption, "`#{meth}` does not have required command method #{name} invoked. " \
                "Ensure it is added after the `desc` task is invoked"
            end
          end
        end

        value
      end

      def __thor_enhance_definition
        @__thor_enhance_definition
      end

      def __thor_enhance_definition=(value)
        @__thor_enhance_definition = value
      end

      def __thor_enhance_definition_stack
        @__thor_enhance_definition_stack ||= []
      end

      private

      def __thor_enhance_access(type:, &block)
        raise ArgumentError, "Expected to receive block. No block given" unless block_given?

        # capture original value. This allows us to do nested enable/disables
        ::Thor.__thor_enhance_definition_stack << ::Thor.__thor_enhance_definition.dup
        ::Thor.__thor_enhance_definition = type

        yield

        nil
      ensure
        # Return the state to the most recently set stack
        ::Thor.__thor_enhance_definition = ::Thor.__thor_enhance_definition_stack.pop
      end
    end
  end
end
