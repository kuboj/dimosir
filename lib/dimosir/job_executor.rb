module Dimosir

  class JobExecutor

    include Loggable

    SLEEP_TIME = 1

    def initialize(l, db, p, tp)
      set_logger(l)
      @db           = db
      @peer_self    = p
      @thread_pool  = tp
    end

    def start
      log(DEBUG, "Starting job executor")
      loop do
        sleep(SLEEP_TIME)
      end
    end

  end

end