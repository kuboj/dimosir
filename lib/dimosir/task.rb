module Dimosir

  class Task

    include MongoMapper::Document

    set_collection_name "tasks"

    key :label,       String,   :required => true, :unique => true
    key :target_host, String,   :required => true
    key :check,       String,   :required => true
    key :arguments,   Hash,     :default  => {}
    key :periodicity, Integer,  :required => true
    belongs_to :peer, :class_name => "Dimosir::Peer"
    many :jobs, :class_name => "Dimosir::Job"

    safe
    timestamps!

    def generate_job(peer_for)
      j = Job.new({
        :task_label => @label,
        :task => self,
        :peer => peer_for
      })

      j.save
      reload
      j
    end

  end

end