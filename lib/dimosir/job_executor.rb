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
        new_jobs = @db.get_unscheduled_jobs(@peer_self)
        new_jobs.each do |job|
          log(DEBUG, "scheduling job '#{job.task_label}'")
          @thread_pool.schedule(job, Proc.new { |j| j.run })
          job.scheduled = true
          job.save
          job.reload
        end

        sleep(SLEEP_TIME)
      end
    end

  end

end