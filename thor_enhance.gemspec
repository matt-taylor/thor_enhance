# frozen_string_literal: true

require_relative "lib/thor_enhance/version"

Gem::Specification.new do |spec|
  spec.name    = "thor_enhance"
  spec.version = ThorEnhance::VERSION
  spec.authors = ["Matt Taylor"]
  spec.email   = ["mattius.taylor@gmail.com"]

  spec.summary     = "Add hooks and human readable components to Thor Options and Thor Commands"
  spec.description = "Have you ever wanted your thor commands to tell a story of what they are? Or have you ever wanted to deprecate an option over time easily? ThorEnhance allows to to annote methods and commands in a human readable way"
  spec.homepage    = "https://github.com/matt-taylor/thor_enhance"
  spec.license     = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 3")

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.3"

  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.17.0"
end
