module Dimosir

  class RRTaskScheduler # RoundRobin

    include Loggable

    def initialize(l)
      set_logger(l)
    end

    def reschedule(peers, tasks)
      log(DEBUG, "Rescheduling tasks")
      i = 0

      tasks.each do |task|
        task.peer = peers[i % peers.size]
        task.save
        i += 1
      end
    end

  end

end