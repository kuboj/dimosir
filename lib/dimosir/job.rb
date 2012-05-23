module Dimosir

  class Job

    include MongoMapper::Document

    set_collection_name "jobs"

    key :done,        Boolean,  :default  => false
    key :done_time,   Date,     :default  => nil
    key :output,      String,   :default  => ""
    key :exitstatus,  Integer,  :default  => nil
    key :task_label,  String,   :required => true
    key :scheduled,   Boolean,  :default  => false
    key :alerted,     Boolean,  :default  => false
    belongs_to :task, :class_name => "Dimosir::Task"
    belongs_to :peer, :class_name => "Dimosir::Peer"

    safe
    timestamps!

    def run
      Loader.load_check(task.check)
      check = Dimosir::Check.const_get(task.check.capitalize).new(task_label, task.target_host, task.arguments)
      @output, @exitstatus = check.perform_check # may take some time. TODO: set timeout somehow
      @done_time = Time.now
      @done = true
      save
      reload
    end

  end

end