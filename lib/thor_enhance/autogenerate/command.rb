# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "thor_enhance/autogenerate/option"
require "erb"

module ThorEnhance
  module Autogenerate
    class Command
      COMMAND_ERB = "#{File.dirname(__FILE__)}/templates/command.rb.erb"
      COMMAND_TEMPLATE = ERB.new(File.read(COMMAND_ERB))

      AGGREGATE_OPTIONS_ERB = "#{File.dirname(__FILE__)}/templates/aggregate_options.rb.erb"
      AGGREGATE_OPTIONS_TEMPLATE = ERB.new(File.read(AGGREGATE_OPTIONS_ERB))

      FOOTER_ERB = "#{File.dirname(__FILE__)}/templates/footer.rb.erb"
      FOOTER_TEMPLATE = ERB.new(File.read(FOOTER_ERB))

      attr_reader :leaf, :name, :basename, :child_commands, :parent

      def initialize(leaf:, name:, basename:, parent: nil)
        @leaf = leaf
        @name = name
        @basename = basename
        @child_commands = []
        @parent = parent
        initialize_children!
      end

      def initialize_children!
        return unless children?

        @child_commands = leaf.children.map do |name, child_leaf|
          self.class.new(leaf: child_leaf, name: name, basename: basename, parent: self)
        end
      end

      def method_options
        @method_options ||= begin
          _options = options.map { |name, option| Option.new(name: name, option: option) }

          _options.group_by { _1.readme_type }
        end
      end

      def command_erb
        @command_erb ||= begin
          params = {
            basename_string: basename_string,
            children_descriptors: children_descriptors,
            command: command,
            description: description,
            drawn_out_examples: drawn_out_examples,
            footer_erb: footer_erb,
            headers: headers,
            method_options_erb: method_options_erb,
            parent_basename_string: parent_basename_string,
            title: title,
          }
          COMMAND_TEMPLATE.result_with_hash(params)
        end
      end

      def footer_erb
        @footer_erb ||=  begin
          regenerate_single_command = "#{parent_basename_string} thor_enhance_autogenerate --command #{command.usage} --apply"
          regenerate_thor_command = "#{basename} thor_enhance_autogenerate --apply"
          FOOTER_TEMPLATE.result_with_hash({ regenerate_single_command: regenerate_single_command, regenerate_thor_command: regenerate_thor_command })
        end
      end

      def drawn_out_examples(with_desc: true)
        case command.example
        when nil
        when Array
          command.example.map do |example|
            value = []
            value << "# #{example[:arguments][:kwargs][:desc]}" if with_desc
            value << "#{parent_basename_string} #{example[:input]}"
            value.join("\n")
          end
        else
          value = []
          value << "# #{example[:arguments][:kwargs][:desc]}" if with_desc
          value << "#{parent_basename_string} #{example[:input]}"
          [value.join("\n")]
        end
      end

      def method_options_erb
        @method_options_erb ||= AGGREGATE_OPTIONS_TEMPLATE.result_with_hash({ method_options: method_options })
      end

      def basename_string
        "#{parent_basename_string} #{command.usage}"
      end

      def parent_basename_string
        parent_names = [basename]
        temp_leaf = leaf
        while parent = temp_leaf.parent
          temp_leaf = parent
          parent_names << parent.command.usage
        end
        parent_names.join(" ")
      end

      def parent_root
        if parent
          # Remove the last index of parent because that will be the Readme.md file
          # We just want the directory of the parent file
          parent.relative_readme_path[0..-2]
        else
          []
        end
      end

      def relative_readme_path
        if children?
          # If children exist, this is a subcommand and needs to be a root ReadMe
          [*parent_root, name, "Readme.md"]
        else
          [*parent_root, "#{name}.md"]
        end
      end

      # this only returns children and its children
      # Call this on top most parent to retreive family tree for subcommands
      def flatten_children
        return [] if child_commands.empty?

        child_commands.map do |child|
          [child, child.flatten_children]
        end.flatten
      end

      def save_self!(root:, apply:)
        absolute_path = "#{root}/#{relative_readme_path.join("/")}"
        pathname = Pathname.new(absolute_path)
        FileUtils.mkdir_p(pathname.dirname)
        if File.exist?(absolute_path)
          content = File.read(absolute_path)
          diff = command_erb == content ? :same : :overwite
        else
          diff = :new
        end

        if apply
          File.write(absolute_path, command_erb)
        end

        { path: absolute_path, diff: diff, apply: apply }
      end

      def description
        command.long_description || command.description
      end

      def title
        command.title || command.usage
      end

      private

      def children_descriptors
        child_commands.map do |child|
          {
            title: child.title,
            link: child.relative_readme_path[-1],
            description: child.description,
            basename_string: child.basename_string,
            examples: child.drawn_out_examples(with_desc: false) || [],
          }
        end
      end

      def headers
        (command.header || []).map { _1[:arguments][:kwargs] }
      end

      def children?
        leaf.children?
      end

      def command
        leaf.command
      end

      def options
        command.options
      end
    end
  end
end