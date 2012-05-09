module Dimosir

  class Job

    include MongoMapper::Document

    set_collection_name "jobs"

    key :done,        Boolean,  :default  => false
    key :done_time,   Date,     :default  => nil
    key :output,      String,   :default  => ""
    key :exitstatus,  Integer,  :default  => nil
    key :task_label,  String,   :required => true
    belongs_to :task, :class_name => "Dimosir::Task"
    belongs_to :peer, :class_name => "Dimosir::Peer"

    safe
    timestamps!

    def run
      raise LoadError, "Could not load '#{task.check}' - check missing" unless Job.check_exists(task.check)

      check = Dimosir::Check.const_get(task.check.capitalize).new(task_label, task.target_host, task.arguments)
      @output, @exitstatus = check.perform_check # may take some time. TODO: set timeout somehow
      @done_time = Time.now
      @done = true
      save
      reload
    end

    def self.check_exists(check_name)
      return Dimosir::Check.const_defined?("#{check_name.capitalize}")
    end

  end

end