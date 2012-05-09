module Dimosir

  module Check

    class Ping < AbstractCheck

      def perform_check
        arg_string = "-c "
        arg_string += @arguments.has_key?("-c") ? @arguments["-c"].to_s : "1"
        output = `ping  #{arg_string} #@target_host`
        retval = $?.exitstatus

        retval
      end

    end

  end

end