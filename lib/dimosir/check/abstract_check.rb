module Dimosir

  module Check

    class AbstractCheck

      include Loggable

      def initialize(task_label, target_host, arguments)
        @task_label   = task_label
        @target_host  = target_host
        @arguments    = arguments
      end

      def perform_check
        raise "This method should be overridden"
      end

    end

  end

end