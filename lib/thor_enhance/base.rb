# frozen_string_literal: true

require "thor"

module ThorEnhance
  module Base
    module BuildOption
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def build_option(name, options, scope)
          # Method is monkey patched in order to make options aware of the klass that creates it if available
          # This allows us to enable and disable required options based on the class
          scope[name] = Thor::Option.new(name, {check_default_type: check_default_type}.merge!(options), self)
        end
      end
    end

    module AllowedKlass
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def thor_enhance_allow!
          ThorEnhance.configuration.allowed_klasses << self
        end
      end
    end
  end
end


