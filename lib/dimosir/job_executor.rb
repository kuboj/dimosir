module Dimosir

  class JobExecutor

    include Loggable

    def initialize(l, tp)
      set_logger(l)
      @thread_pool = tp
    end

  end

end