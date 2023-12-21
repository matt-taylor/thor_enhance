# frozen_string_literal: true

module ThorEnhance
  class Tree
    DEFAULT_IGNORE_COMMANDS = ["help", "thor_enhance_autogenerate"]

    def self.add_ignore_commands(command)
      return false if ignore_commands.include?(command)

      ignore_commands << command
      true
    end

    def self.ignore_commands
      @ignore_commands ||= DEFAULT_IGNORE_COMMANDS.dup
    end

    def self.reset_ignore_commands!
      @ignore_commands = DEFAULT_IGNORE_COMMANDS.dup
    end

    def self.tree(base:, parent: nil)
      raise TreeFailure, "#{base} does not respond to all_commands. Unable to continue" unless base.respond_to?(:all_commands)

      base.all_commands.map do |k, command|
        next if ignore_commands.include?(k)

        [k, new(command: command, base: base, parent: parent)]
      end.compact.to_h
    end

    attr_reader :command, :base, :parent, :children

    # command: Thor::Command struct
    # base: Root level class where the command is from
    # parent: 1 level up if nested subcommand
    def initialize(command:, base:, parent: nil)
      @parent = parent
      @base = base
      @command = command
      @children = {}

      if !base.subcommand_classes.nil? && base.subcommand_classes[command.name]
        @children = self.class.tree(parent: self, base: base.subcommand_classes[command.name])
      end
    end

    def class_options
      base.class_options
    end

    def children?
      children.count > 0
    end
  end
end
