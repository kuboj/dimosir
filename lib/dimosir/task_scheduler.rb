module Dimosir

  class TaskScheduler

    include Loggable

    def initialize(l)
      set_logger(l)
    end

    def reschedule(peers, tasks)
      raise "This method has to be overridden"
    end

  end

end