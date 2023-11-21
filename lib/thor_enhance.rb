# frozen_string_literal: true

require "thor_enhance/command"
require "thor_enhance/command_hook"
require "thor_enhance/command_method"
require "thor_enhance/configuration"
require "thor_enhance/option"
require "thor_enhance/tree"

module ThorEnhance
  class BaseError < StandardError; end
  class OptionNotAllowed < StandardError; end
  class ValidationFailed < StandardError; end
  class RequiredOption < StandardError; end
  class OptionDeprecated < StandardError; end

  def self.configure
    yield configuration if block_given?

    configuration.inject_thor!
  end

  def self.configuration
    @configuration ||= ThorEnhance::Configuration.new
  end
end
