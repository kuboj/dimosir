module Dimosir

  class TaskScheduler

    include Loggable

    @db

    def initialize(l, db)
      set_logger(l)
      @db = db
    end

    def reschedule_all
      log(DEBUG, "Rescheduling all")
      tasks = @db.get_all_tasks
      peers = @db.get_all_peers
      i = 0

      tasks.each do |task|
        task.peer = peers[i % peers.size]
        task.save
        i += 1
      end
    end

  end

end