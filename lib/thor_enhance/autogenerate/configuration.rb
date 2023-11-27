# frozen_string_literal: true

module ThorEnhance
  module Autogenerate
    class Configuration
      attr_reader :configuration

      def initialize(required: false)
        @required = required
        @configuration = { add_option_enhance: {}, add_command_method_enhance: {} }
      end

      def set_default_required(value)
        @required = value
      end

      def default
        ThorEnhance::Configuration.allow_changes?

        example
        readme
      end

      def example(required: nil, repeatable: true)
        ThorEnhance::Configuration.allow_changes?

        required = required.nil? ? @required : required
        configuration[:add_command_method_enhance][:example] = { repeatable: repeatable, required: required }
      end

      def readme(required: nil, enums: [:important, :advanced])
        ThorEnhance::Configuration.allow_changes?

        required = required.nil? ? @required : required
        configuration[:add_option_enhance][:readme] = { enums: enums, required: required }
      end
    end
  end
end
