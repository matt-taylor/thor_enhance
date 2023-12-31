# frozen_string_literal: true

require "erb"

module ThorEnhance
  module Autogenerate
    class Option
      TEMPLATE_ERB = "#{File.dirname(__FILE__)}/templates/option.rb.erb"
      OPTION_TEMPLATE = ERB.new(File.read(TEMPLATE_ERB))

      attr_reader :name, :option

      def initialize(name:, option:)
        @name = name
        @option = option
      end

      def template_text
        text = []
        text << "# What: #{option.description}"
        text << "# Type: #{option.type}"
        text << "# Required: #{option.required}"
        text << "# Allowed Inputs: #{option.enum}" if option.enum
        text << invocations.map { "#{_1}"}.join(" | ")

        text.join("\n")
      end

      def invocations
        base = [option.switch_name] + option.aliases
        if option.type == :boolean
          counter = option.switch_name.sub("--", "--no-")
          base << counter
        end

        base
      end

      def readme_type
        option.readme || ThorEnhance.configuration.autogenerated_config.readme_empty_group
      end
    end
  end
end
