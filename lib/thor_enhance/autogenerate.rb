# frozen_string_literal: true

require "thor_enhance/autogenerate/configuration"
require "thor_enhance/autogenerate/validate"
require "thor_enhance/autogenerate/option"
require "thor_enhance/autogenerate/command"

module ThorEnhance
  module Autogenerate
    module_function

    ROOT_ERB = "#{File.dirname(__FILE__)}/autogenerate/templates/root.rb.erb"
    ROOT_TEMPLATE = ERB.new(File.read(ROOT_ERB))

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
      saved_status = commands.map do |command|
        command.save_self!(root: full_root, apply: apply)
      end
      self_for_roots =  saved_status.collect { _1[:self_for_root] }
      saved_status << root_savior!(apply: apply, full_root: full_root, self_for_roots: self_for_roots)

      { status: :pass, saved_status: saved_status }
    end

    def root_savior!(full_root:, self_for_roots:, apply:)
      full_path = "#{full_root}/Readme.md"
      root_erb_result = self_for_roots.map do |root_child|
        ROOT_TEMPLATE.result_with_hash({ root_child: root_child })
      end.join("\n")

      FileUtils.mkdir_p(full_root)
      if File.exist?(full_path)
        content = File.read(full_path)
        diff = root_erb_result == content ? :same : :overwite
      else
        diff = :new
      end

      if apply
        File.write(full_path, root_erb_result)
      end

      { path: full_path, diff: diff, apply: apply }
    end
  end
end
