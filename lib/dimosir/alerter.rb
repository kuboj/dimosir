require "pony"

module Dimosir

  class Alerter

    include Loggable

    @db

    def initialize(l, db, mail_opts)
      set_logger(l)
      @db = db
      parsed = mail_opts.inject({}) { |memo,(k,v)| memo[k.to_sym] = v; memo }
      parsed[:via_options] = parsed[:via_options].inject({}) { |memo,(k,v)| memo[k.to_sym] = v; memo }
      parsed[:via] = parsed[:via].to_sym
      Pony.options = parsed
    end

    def check
      jobs = @db.get_notalerted_jobs
      jobs.each { |j| send_alert(j); j.alerted = true; j.save }
    end

    def send_alert(job)
      log(INFO, "Sending alert. '#{job.task_label}' failed with status #{job.exitstatus}")
      Pony.mail(:body => "#{job.task_label} failed.\ntarget host:#{job.task.target_host}\nstatus: #{job.exitstatus}\noutput: #{job.output}")
    end

  end

end