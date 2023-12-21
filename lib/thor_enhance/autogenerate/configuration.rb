# frozen_string_literal: true

module ThorEnhance
  module Autogenerate
    class Configuration
      attr_reader :question_headers, :custom_headers, :configuration, :readme_empty_group, :readme_skip_key, :readme_enums

      DEFAULT_SKIP_KEY = :skip

      def initialize(required: false)
        @required = required
        @configuration = { add_option_enhance: {}, add_command_method_enhance: {} }
        @readme_enums = []
        @custom_headers = []
        @question_headers = []
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

        configuration[:add_command_method_enhance][:header] = { repeatable: true, required: false, required_kwargs: [:name, :desc], optional_kwargs: [:tag] }
      end

      def custom_header(name, question: false, repeatable: false, required: false)
        ThorEnhance::Configuration.allow_changes?

        raise ArgumentError, "Custom Header name must be unique. #{name} is already defined as a custom header. " if custom_headers.include?(name.to_sym)

        custom_headers << name.to_sym
        question_headers << name.to_sym if question
        configuration[:add_command_method_enhance][name.to_sym] = { repeatable: repeatable, required: required, optional_kwargs: [:tag] }
      end

      def readme(required: nil, empty_group: :unassigned, skip_key: DEFAULT_SKIP_KEY, enums: [:important, :advanced, skip_key.to_sym].compact)
        ThorEnhance::Configuration.allow_changes?

        @readme_empty_group = empty_group.to_sym
        @readme_skip_key = skip_key
        @readme_enums = enums.map(&:to_sym) << empty_group.to_sym
        required = required.nil? ? @required : required
        configuration[:add_option_enhance][:readme] = { enums: enums, required: required }
      end
    end
  end
end
