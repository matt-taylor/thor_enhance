# frozen_string_literal: true

module ThorEnhance
  module Autogenerate
    module Validate
      def self.validate(options:, root: nil)
        root_result = validate_root(options: options, root: root)
        return root_result if root_result[:status] != :pass

        trunk = root_result[:trunk]
        constant = root_result[:constant]

        subcommand_result = validate_subcommand(options: options, trunk: trunk)
        return subcommand_result if subcommand_result[:status] != :pass

        trunk = subcommand_result[:trunk]
        command_result = validate_command(options: options, trunk: trunk, constant: constant)
        return command_result if command_result[:status] != :pass
        command = command_result[:command]

        { command: command, trunk: trunk, constant: constant, status: :pass }
      end

      def self.validate_root(options:, root:)
        begin
          constant = root || Object.const_get(options.root)
        rescue NameError => e
          msg_array = [
            "Unable to load provided --root|-r option `#{options.root}`",
            "Please check the spelling and ensure the klass has loaded"
          ]
          return { error: e, msg_array: msg_array, status: :fail }
        end

        begin
          trunk = ThorEnhance::Tree.tree(base: constant)
        rescue TreeFailure => e
          msg_array = [
            "--root|-r option is not a Thor klass.",
            "Please ensure that the provided klass is a child of Thor"
          ]
          return { error: e, msg_array: msg_array, status: :fail }
        end

        { trunk: trunk, constant: constant, status: :pass }
      end

      def self.validate_command(options:, trunk:, constant:)
        # Return early when command is not present in the options object
        command = options.command
        return { status: :pass, trunk: trunk, command: nil } if command.nil?

        # Return early when command is found in the tree trunk
        command = trunk.children[options.command] rescue trunk[options.command]
        return { status: :pass, trunk: trunk, command: command } if command

        # Command option was available but command was not found in the trunk
        msg_array = ["Failed to find --command|-c `#{options.command}`"]
        msg_array << "Provided root command `#{constant}`"
        msg_array << "With Provided subcommand `#{options.subcommand}`" if options.subcommand
        msg_array << "does not have command `#{options.command}` as a child" if options.subcommand

        { msg_array: msg_array, status: :fail }
      end

      def self.validate_subcommand(options:, trunk:)
        subcommands = options.subcommand
        return { trunk: trunk, status: :pass } if subcommands.nil?

        subcommands = subcommands.dup
        subcommand = subcommands.shift
        temp_trunk = trunk[subcommand]
        while subcommand != nil
          if temp_trunk.nil? || !temp_trunk.children?
            msg_array = [
              "Order is important with --subcommands|-s options",
              "Provided with: #{options.subcommand}",
              "Subcommand `#{subcommand}` does not have any child commands",
              "Every provided subcommand must have children",
              "If the subcommand `#{subcommand}` is meant to be a command",
              "Pass `#{subcommand}` in as `--command|-c #{subcommand}` instead",
            ]
            return { msg_array: msg_array, status: :fail }
          end
          subcommand = subcommands.shift
          # Will always be in the child hash at this point if subcommand exists
          temp_trunk = temp_trunk.children[subcommand] if subcommand
        end

        { trunk: temp_trunk, subcommands: options.subcommand, status: :pass }
      end
    end
  end
end
