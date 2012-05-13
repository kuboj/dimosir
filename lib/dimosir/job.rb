module Dimosir

  class Job

    GET_STATS_TEMP_COLLECTION = "job_stats_mapreduce"

    include MongoMapper::Document

    set_collection_name "jobs"

    key :done,        Boolean,  :default  => false
    key :done_time,   Date,     :default  => nil
    key :output,      String,   :default  => ""
    key :exitstatus,  Integer,  :default  => nil
    key :task_label,  String,   :required => true
    key :scheduled,   Boolean,  :default  => false
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

    def self.get_stats
      map =
        <<-JS
        function() {
          emit(this.task_id, {task_label: this.task_label, exitstatus: this.exitstatus});
        }
        JS

      reduce =
        <<-JS
        function(key, values) {
          var statuses = {};
          var successful = 0;
          var unsuccessful = 0;
          for (var i = 0; i < values.length; i++) {
            var exitstatus = values[i]["exitstatus"];
            if (statuses[exitstatus] == undefined) {
              statuses[exitstatus] = 0;
            }

            // convert floats to integers, see https://jira.mongodb.org/browse/SERVER-854
            statuses[exitstatus] = NumberInt(statuses[exitstatus] + 1);
            if (exitstatus == 0) {
              successful++;
            } else {
              unsuccessful++;
            }
          }

          return {
            task_label: values[0]["task_label"],
            successful: NumberInt(successful),
            unsuccessful: NumberInt(unsuccessful),
            statuses: statuses
          }
        }
        JS

      opts = {
        :query => {:done => true},
        :out => GET_STATS_TEMP_COLLECTION
      }
      stats = Job.collection.map_reduce(map, reduce, opts).find
      out = []
      stats.each { |s| out << s }

      out
    end

  end

end