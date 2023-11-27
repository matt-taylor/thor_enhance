# frozen_string_literal: true

require "thor_enhance/autogenerate/configuration"
require "thor_enhance/autogenerate/validate"

module ThorEnhance
  module Autogenerate
    module_function

    def execute!(options:, root: nil)
      validate_result = Validate.validate(options: options, root: root)
      return validate_result if validate_result[:status] != :pass

      { status: :pass }
    end
  end
end
