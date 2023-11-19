# frozen_string_literal: true

require "faraday"

module ThorEnhance

  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= ThorEnhance::Configuration.new
  end

  def self.configuration=(object)
    raise ConfigError, "Expected configuration to be a ThorEnhance::Configuration" unless object.is_a?(ThorEnhance::Configuration)

    @configuration = object
  end

  def self.reset_configuration!
    @configuration = ThorEnhance::Configuration.new
  end
end
