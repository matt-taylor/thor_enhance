# frozen_string_literal: true

require "thor"

module ThorEnhance
  class Configuration
    HOOKERS = [DEPRECATE = :deprecate, HOOK = :hook]
    ALLOWED_VALUES = [DEFAULT_ALLOWED = nil, ALLOW_ALL = :all]

    class << self
      def allow_changes?(raise_error: true)
        # binding.pry

        return true unless defined?(@@allow_changes)
        return true if @@allow_changes.nil?

        if raise_error
          raise BaseError, "Configuration changes are halted. Unable to change ThorEnhancements"
        else
          false
        end
      end

      def disallow_changes!
        @@allow_changes = :prevent
      end
    end

    def inject_thor!
      self.class.allow_changes?

      ThorEnhance::Option.thor_enhance_injection!
      ThorEnhance::Command.thor_enhance_injection!
      ThorEnhance::CommandMethod.thor_enhance_injection!

      ############
      # Commands #
      ############
      # Prepend it so we can call our run method first
      ::Thor::Command.prepend ThorEnhance::CommandHook
      ::Thor::Command.include ThorEnhance::Command

      ##################
      # Command Method #
      ##################
      ::Thor.include ThorEnhance::CommandMethod

      ###########
      # Options #
      ###########
      # Must be prepended because we change the arity of the initializer here
      ::Thor::Option.prepend ThorEnhance::Option
      ::Thor.include ThorEnhance::Base::BuildOption

      ####################
      # Other Injections #
      ####################
      ::Thor.include ThorEnhance::Base::AllowedKlass

      self.class.disallow_changes!
    end

    def command_method_enhance
      @command_method_enhance ||= {}
    end

    def allowed_klasses
      @klass_procs ||= []
    end

    def allowed
      @allowed ||= DEFAULT_ALLOWED
    end

    def allowed=(value)
      raise ArgumentError, "Unexpected value for `allowed =`. Given: #{value}. Expected one of #{ALLOWED_VALUES}" unless ALLOWED_VALUES.include?(value)

      @allowed = value
    end

    def allowed?(klass)
      return true if allowed == ALLOW_ALL
      return true if allowed_klasses.include?(klass)

      # At this point, allowed is false and not an includable klass -- dont allow
      false
    end

    def option_enhance
      @option_enhance ||= {
        DEPRECATE => { allowed_klasses: [Proc], behavior: :request, required: false },
        HOOK => { allowed_klasses: [Proc], behavior: nil, required: false },
      }
    end

    # Adding a new method to enhance the overall command
    def add_command_method_enhance(name, allowed_klasses: nil, enums: nil, required: false, repeatable: false)
      self.class.allow_changes?

      add_to_variable(command_method_enhance, ::Thor::Command.instance_methods, name, allowed_klasses, enums, required, repeatable)
    end

    # add a new flag on the command option
    def add_option_enhance(name, allowed_klasses: nil, enums: nil, required: false)
      self.class.allow_changes?

      add_to_variable(option_enhance, ::Thor::Option.instance_methods, name, allowed_klasses, enums, required)
    end

    private

    def add_to_variable(storage, methods, name, allowed_klasses, enums, required, repeatable = false)
      # Reject if the name is not a Symbol or a string
      if [String, Symbol].none? { _1 === name }
        raise ArgumentError, "Invalid name type received. Received [#{name}] of type [#{name.class}]. Expected to be of type String or Symbol"
      end

      # If name contains characters other than upper or lower case letters and _ FAIL
      unless name =~ /^[A-Za-z_]+$/
        raise ArgumentError, "Invalid name received. Received [#{name}] does not match /^[A-Za-z_]+$/."
      end

      if methods.include?(name.to_sym)
        raise OptionNotAllowed, "[#{name}] is not allowed as an enhancement"
      end

      if storage.key?(name.to_sym)
        raise OptionNotAllowed, "Duplicate detected. [#{name}] was already added."
      end

      # if enums is present and not an array
      if !enums.nil? && !enums.is_a?(Array)
        raise ArgumentError, "Recieved enums with #{enums}. When present, it is expected to be an Array"
      end

      # if allowed_klasses is present and not an array
      if !allowed_klasses.nil? && !allowed_klasses.is_a?(Array)
        raise ArgumentError, "Recieved allowed_klasses with #{allowed_klasses}. When present, it is expected to be an Array"
      end

      storage[name.to_sym] = { allowed_klasses: allowed_klasses, enums: enums, required: required, repeatable: repeatable }
    end
  end
end
