module Dimosir

  module Check

    class Host < AbstractCheck

      def perform_check
        output = `host #{@arguments["lookup"]} #@target_host`
        retval = $?.exitstatus

        [output, retval]
      end

    end

  end

end