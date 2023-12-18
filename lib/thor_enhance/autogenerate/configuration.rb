# frozen_string_literal: true

module ThorEnhance
  module Autogenerate
    class Configuration
      attr_reader :configuration, :readme_empty_group, :readme_skip_key, :readme_enums

      DEFAULT_SKIP_KEY = :skip

      def initialize(required: false)
        @required = required
        @configuration = { add_option_enhance: {}, add_command_method_enhance: {} }
        @readme_enums = []
      end

      def set_default_required(value)
        @required = value
      end

      def default
        ThorEnhance::Configuration.allow_changes?

        example
        header
        title
        readme
      end

      def title(required: false)
        ThorEnhance::Configuration.allow_changes?

        required = required.nil? ? @required : required
        configuration[:add_command_method_enhance][:title] = { repeatable: false, required: required }
      end

      def example(required: nil, repeatable: true)
        ThorEnhance::Configuration.allow_changes?

        required = required.nil? ? @required : required
        configuration[:add_command_method_enhance][:example] = { repeatable: repeatable, required: required, required_kwargs: [:desc] }
      end

      def header
        ThorEnhance::Configuration.allow_changes?

        configuration[:add_command_method_enhance][:header] = { repeatable: true, required: false, required_kwargs: [:name, :desc] }
      end

      def readme(required: nil, empty_group: :unassigned, skip_key: DEFAULT_SKIP_KEY, enums: [:important, :advanced, skip_key.to_sym].compact)
        ThorEnhance::Configuration.allow_changes?

        @readme_empty_group = empty_group
        @readme_skip_key = skip_key
        @readme_enums = enums
        required = required.nil? ? @required : required
        configuration[:add_option_enhance][:readme] = { enums: enums, required: required }
      end
    end
  end
end
