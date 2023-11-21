# frozen_string_literal: true

if ENV['CI'] == 'true'
  require 'simplecov'
  # Needs to be loaded prior to application start
  SimpleCov.start do
    add_filter 'spec/'
  end
end

require 'thor_enhance'
require 'faker'
require 'pry'

ThorEnhance.configure do |c|
  c.add_option_enhance "classify", enums: ["allowed", "helpful", "removed", "warn", "hook"], required: true
  c.add_option_enhance "revoke", allowed_klasses: [TrueClass, FalseClass], required: false
  c.add_command_method_enhance "human_readable", required: true
  c.add_command_method_enhance "example", repeatable: true
end

class MyTestClass < Thor
  class SubCommand < Thor
    desc "innard", "Innard testing task"
    example "bin/thor sub innard -t something"
    method_option :t, type: :string, classify: "allowed"
    def innard;end;
  end

  desc "sub", "Submodule command line"
  human_readable "Subcommand Module"
  example "bin/thor sub ***"
  subcommand "sub", SubCommand

  desc "test_meth", "short description"
  human_readable "Thor Test command"
  example "bin/thor test_meth"
  example "bin/thor test_meth --test_meth_option"

  method_option :test_meth_option, type: :boolean, desc: "Tester", classify: "allowed"
  method_option :option1, type: :boolean, desc: "Option1", classify: "removed", deprecate: ->(v) { "Please migrate to --option3" }
  method_option :option2, type: :boolean, desc: "Option2", classify: "warn", warn: ->(v) { "Option will be deprecated in next release. Migrate to --option3" }
  method_option :option3, type: :boolean, desc: "Option3", classify: "hook", hook: ->(v) { Kernel.puts "This is the correct option to use" }
  def test_meth;end;
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
