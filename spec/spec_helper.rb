# frozen_string_literal: true

if ENV["CI"] == "true"
  require "simplecov"
  # Needs to be loaded prior to application start
  SimpleCov.start do
    add_filter "spec/"
    enable_coverage :branch
  end

  ENV["THOR_ENHANCE_GENERATED_ROOT_PATH"] = "#{ENV["HOME"]}/#{ENV["CIRCLE_PROJECT_REPONAME"]}"
end

require "thor_enhance"
require "pry"
require "ice_age"

ThorEnhance.configure do |c|
  c.readme_enhance! do |r|
    r.custom_header :what_do_you_meme
    r.custom_header :extra_links
    r.custom_header :how_to_integrate
    r.custom_header :empty_header
    r.custom_header :empty_header_two
  end
  c.add_option_enhance "classify", enums: ["allowed", "helpful", "removed", "deprecate", "hook"], required: true
  c.add_option_enhance "revoke", allowed_klasses: [TrueClass, FalseClass], required: false
  c.add_command_method_enhance "human_readable", required: true
  c.add_command_method_enhance "counter", allowed_klasses: [Integer, String]
  c.add_command_method_enhance "counter_enum", enums: [:allowed, :skip]
end


class MyTestClass < Thor
  thor_enhance_allow!
  class_option :verbose, type: :boolean, desc: "Verbose level", classify: "allowed"


  class SubCommand < Thor
    thor_enhance_allow!

    class_option :verbose, type: :boolean, desc: "Verbose level", classify: "allowed"

    desc "innard", "Innard testing task"
    example "innard -t something", desc: "some imporatn description"
    human_readable "required"

    method_option :t, type: :string, classify: "allowed"
    def innard;end;
  end

  desc "sub", "Submodule command line"
  subcommand "sub", SubCommand

  desc "test_meth", "short description"
  human_readable "Thor Test command"
  what_do_you_meme "Order is important. This header will be first", tag: 1
  how_to_integrate "This will be the second header with header tag 3", tag: "h3"
  extra_links <<~README
  - (Some Cool Link)[https://google.com]
  - (Some Cool Repo)[https://github.com/matt-taylor/thor_enhance]
  README
  empty_header "This is empty", tag: "Bad Header"
  example "test_meth", desc: "basoc interpretation"
  example "test_meth --test_meth_option", desc: "With custom method"

  method_option :test_meth_option, type: :boolean, desc: "Tester", classify: "allowed", readme: :important
  method_option :test_meth_option2, type: :string, desc: "Tester", classify: "allowed", readme: :important
  method_option :option1, type: :boolean, desc: "Option1", classify: "deprecate", deprecate: ->(v, option) { "Please migrate to --option4" }, readme: :important
  method_option :option2, type: :boolean, desc: "Option2", classify: "deprecate", deprecate: ->(v, option) { { raise: false, warn: "Option will be deprecated in next release.", msg: "Migrate to --option4" } }, readme: :important
  method_option :option3, type: :boolean, desc: "Option3", classify: "deprecate", deprecate: ->(v, option) { { raise: true, warn: "Option will be deprecated in next release.", msg: "Migrate to --option4" } }, readme: :important
  method_option :option4, type: :boolean, desc: "Option4", classify: "hook", hook: ->(v, option) { Kernel.puts "This is the correct option to use" }, readme: :important
  method_option :option5, type: :boolean, desc: "Option5", classify: "deprecate", deprecate: ->(v, option) { { warn: "Options Are missing. This will raise" } }, readme: :important
  def test_meth;end;
end

class TestAccessPatterns < Thor
  thor_enhance_allow!

  disable_thor_enhance! do
    desc "test_meth", "short description"
    method_option :enhance, type: :boolean, desc: "Tester"
    def test_meth; end;

    # Only enable classify method option; human readable method is disabled
    enable_thor_enhance! do
      desc "test_meth2", "short description"
      human_readable "Thor Test command"
      method_option :enhance, type: :boolean, desc: "Tester", classify: "allowed"
      def test_meth2; end;

      desc "test_meth4", "short description"
      human_readable "Thor Test command"
      method_option :enhance, type: :boolean, desc: "Tester", classify: "allowed"
      def test_meth4; end;
    end

    desc "test_meth3", "short description"
    method_option :enhance, type: :boolean, desc: "Tester"
    def test_meth3; end;
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 2
  config.order = :random
  Kernel.srand config.seed
end
