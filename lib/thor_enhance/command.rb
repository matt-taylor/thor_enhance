# frozen_string_literal: true

require "thor"

module ThorEnhance
  module Command
    def self.thor_enhance_injection!
      return false unless ThorEnhance::Configuration.allow_changes?

      # Create Thor::Command getter and setter methods -- Validation gets done on setting
      ThorEnhance.configuration.command_method_enhance.each do |name, object|
        define_method(name) { instance_variable_get("@#{name}") }
        define_method("#{name}=") { instance_variable_set("@#{name}", _1) }
      end
    end
  end
end
