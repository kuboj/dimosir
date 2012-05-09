module Dimosir

  class JobGenerator

    include Loggable

    @db
    @tasks

    @tasks_mutex

    def initialize(l, db, peer_self, sleep_time)
      set_logger(l)

      @db           = db
      @peer_self    = peer_self
      @tasks_mutex  = Mutex.new
      @sleep_time   = sleep_time
    end

    def start
      reload_tasks
      Thread.new { start_generating }
    end

    def start_generating
      loop do
        @tasks.each do |task, last_run|
          task.generate_job(peer_self) if Time.now.to_i - last_run > task.periodicity
        end

        sleep(sleep_time)
      end
    end

    def reload_tasks
      log(INFO, "Reloading tasks")
      tasks_old = @tasks
      tasks_old_str = ""
      tasks_old.each { |task| tasks_old_str += "#{task.label}, " }
      tasks_new = {}

      tasks_new_raw = @db.get_tasks(@peer_self)
      tasks_new_raw.each do |task|
        if tasks_old.key_exists?(task)
          tasks_new[task] = tasks_old[task]
        else
          tasks_new[task] = 0 # task was never run
        end
      end

      @tasks_mutex.synchronize { @tasks = tasks_new }
    end

  end

end