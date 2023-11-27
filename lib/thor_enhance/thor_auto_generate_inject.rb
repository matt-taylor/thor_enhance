# frozen_string_literal: true

####################
#
# Injects a method directly into the thor base class
# This allows the developer to have this convenience method
# Just by utilizing ThorEnhance
#
####################
require "thor"

class Thor
  desc "thor_enhance_autogenerate", "Auto Generate ReadMe material for your Thor commands"
  method_option :subcommand, aliases: "-s", type: :string, repeatable: true, desc: "When provided, autogeneration will execute on the subcommand"
  method_option :command, aliases: "-c", type: :string, desc: "When provided, autogeneration will occur only on this method. Note: When used with subcommand, method must exist on subcommand"
  method_option :executable, aliases: "-e", type: :string, default: File.basename($0), desc: "The name of the file that executes the Thor script"

  # :nocov:
  def thor_enhance_autogenerate
    require "thor_enhance/autogenerate"
    result = ThorEnhance::Autogenerate.execute!(options: options, root: self.class)

    __auto_generate_fail!(result[:msg_array]) if result[:status] != :pass
  end

  no_tasks do
    def __auto_generate_fail!(msg_array)
      say_error set_color("*********************** FAILED OPERATION ***********************", :red, :bold)
      say_error set_color("FAIL: Unable to continue", :red, :bold)
      msg_array.each do |line|
        say_error set_color("FAIL: #{line}", :red, :bold)
      end
      say_error set_color("*********************** FAILED OPERATION ***********************", :red, :bold)
      exit 1
    end
  end
  # :nocov:
end
