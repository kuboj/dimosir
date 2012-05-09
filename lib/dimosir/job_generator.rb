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
          if Time.now.to_i - last_run > task.periodicity
            log(DEBUG, "Generating job for task #{task.label}")
            task.generate_job(peer_self)
          end
        end

        sleep(sleep_time)
      end
    end

    def reload_tasks
      log(INFO, "Reloading tasks")
      tasks_old = @tasks
      tasks_old_str = ""
      tasks_old.each { |task| tasks_old_str += "#{task.label}, " }
      log(DEBUG, "Old tasks: #{tasks_old_str}")
      tasks_new = {}

      tasks_new_raw = @db.get_tasks(@peer_self)
      tasks_new_str = ""
      tasks_new_raw.each do |task|
        tasks_old_str += "#{task.label}, "
        if tasks_old.key_exists?(task)
          tasks_new[task] = tasks_old[task]
        else
          tasks_new[task] = 0 # task was never run
        end
      end
      log(DEBUG, "New tasks: #{tasks_new_str}")

      @tasks_mutex.synchronize { @tasks = tasks_new }
    end

  end

end