module Dimosir

  class JobGenerator

    include Loggable

    SLEEP_TIME = 1 # TODO: put this in app_config

    @db
    @tasks

    @tasks_mutex

    def initialize(l, db, peer_self)
      set_logger(l)

      @db           = db
      @peer_self    = peer_self
      @tasks_mutex  = Mutex.new

      @tasks        = {}
    end

    def start
      reload_tasks
      Thread.new { start_generating }
    end

    def start_generating
      loop do
        @tasks_mutex.synchronize do
          @tasks.each do |task, last_run|
            if Time.now.to_i - last_run > task.periodicity
              log(DEBUG, "Generating job for task #{task.label}")
              task.generate_job(@peer_self)
              @tasks[task] = Time.now.to_i
            end
          end
        end

        sleep(SLEEP_TIME)
      end
    end

    def reload_tasks
      log(INFO, "Reloading tasks")
      tasks_old = @tasks
      tasks_old_str = ""
      tasks_old.each { |task, _| tasks_old_str += "#{task.label}, " }
      log(DEBUG, "Old tasks: #{tasks_old_str}")
      tasks_new = {}

      tasks_new_raw = @db.get_tasks(@peer_self)
      tasks_new_str = ""
      tasks_new_raw.each do |task|
        tasks_new_str += "#{task.label}, "
        if tasks_old.has_key?(task)
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