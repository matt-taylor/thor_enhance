# frozen_string_literal: true

require "thor_enhance/base"
require "thor_enhance/command"
require "thor_enhance/command_hook"
require "thor_enhance/command_method"
require "thor_enhance/configuration"
require "thor_enhance/option"
require "thor_enhance/thor_auto_generate_inject"
require "thor_enhance/tree"

module ThorEnhance
  class BaseError < StandardError; end
  class OptionNotAllowed < BaseError; end
  class ValidationFailed < BaseError; end
  class RequiredOption < BaseError; end
  class OptionDeprecated < BaseError; end
  class TreeFailure < BaseError; end
  class AutoGenerateFailure < BaseError; end

  def self.configure
    yield configuration if block_given?

    configuration.inject_thor!
  end

  def self.configuration
    @configuration ||= ThorEnhance::Configuration.new
  end
end
