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
        Command.new(name: name, leaf: leaf, basename: basename)
      end

      # flatten_children returns all kids, grandkids, great grandkids etc of the commands returned from the above mapping
      youthful_kids = command_structure.map(&:flatten_children).flatten
      children_result = save_generated_readmes!(commands: youthful_kids, generated_root: options.generated_root, apply: options.apply)
      return children_result if children_result[:status] != :pass

      root_result = save_generated_readmes!(commands: command_structure, generated_root: options.generated_root, apply: options.apply)
      return root_result if root_result[:status] != :pass

      self_for_roots = root_result[:saved_status].collect { _1[:self_for_root] }
      # Add saved results from the children
      root_result[:saved_status] += children_result[:saved_status]
      # Add root savior saved results
      root_result[:saved_status] << root_savior!(basename: basename, apply: options.apply, full_root: root_result[:full_root], self_for_roots: self_for_roots)

      root_result
    end

    def save_generated_readmes!(commands:, generated_root:, apply:)
      parent = generated_root || ENV["THOR_ENHANCE_GENERATED_ROOT_PATH"]
      full_root = "#{parent}/commands"
      saved_status = commands.map do |command|
        command.save_self!(root: full_root, apply: apply)
      end

      { status: :pass, full_root: full_root, saved_status: saved_status }
    end

    def root_savior!(basename:, full_root:, self_for_roots:, apply:)
      full_path = "#{full_root}/Readme.md"
      regenerate_thor_command = "#{basename} thor_enhance_autogenerate --apply"
      footer = ThorEnhance::Autogenerate::Command::FOOTER_TEMPLATE.result_with_hash({ regenerate_thor_command: regenerate_thor_command })

      root_erb_result = (self_for_roots.map do |root_child|
        ROOT_TEMPLATE.result_with_hash({ root_child: root_child })
      end + [footer]).join("\n")

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
