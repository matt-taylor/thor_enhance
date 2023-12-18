# frozen_string_literal: true

require "thor_enhance/autogenerate/configuration"
require "thor_enhance/autogenerate/validate"
require "thor_enhance/autogenerate/option"
require "thor_enhance/autogenerate/command"

module ThorEnhance
  module Autogenerate
    module_function

    def execute!(options:, basename: File.basename($0), root: nil)
      validate_result = Validate.validate(options: options, root: root)
      return validate_result if validate_result[:status] != :pass

      command = validate_result[:command]
      trunk = validate_result[:trunk]

      leaves =
        if command
          { options.command => command }
        elsif Hash === trunk
          # Parent trunk is a hash -- structure needs to change
          trunk
        else
          # if not parent, grab the children
          trunk.children
        end

      command_structure = leaves.map do |name, leaf|
        parent = Command.new(name: name, leaf: leaf, basename: basename)
      end

      # flatten_children returns all kids, grandkids, great grandkids etc of the commands returned from the above mapping
      youthful_kids = command_structure.map(&:flatten_children).flatten

      # this is a flat map of the entire family tree. Each node knows where it is so we can flatten it
      family_tree = command_structure + youthful_kids

      save_generated_readmes!(commands: family_tree, generated_root: options.generated_root, apply: options.apply)
    end

    def save_generated_readmes!(commands:, generated_root:, apply:)
      parent = generated_root || ENV["THOR_ENHANCE_GENERATED_ROOT_PATH"]
      full_root = "#{parent}/commands"
      binding.pry
      saved_status = commands.map do |command|
        command.save_self!(root: full_root, apply: apply)
      end

      { status: :pass, saved_status: saved_status}
    end
  end
end
