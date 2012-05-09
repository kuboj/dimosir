require "spec_helper"

describe Dimosir::Task do

  describe "#new" do

    it "creates new empty task" do
      t = Dimosir::Task.new({
        :label => "testing task",
        :target_host => "host",
        :check => "ping",
        :periodicity => 60
      })
      t.should be_instance_of Dimosir::Task
      t.save.should eql true
    end

    it "won't create task with missing fields" do
      t = Dimosir::Task.new({:label => "test"})
      t.save.should eql false
    end

    it "won't create task with existing label" do
      t1 = Dimosir::Task.create({
        :label => "testing task",
        :target_host => "host",
        :check => "ping",
        :periodicity => 60
      })
      t2 = Dimosir::Task.new({
        :label => "testing task",
        :target_host => "host",
        :check => "ping",
        :periodicity => 60
      })
      t2.save.should be_false
    end

  end

  describe "#generate_job" do

    it "creates new job" do
      t = Dimosir::Task.create({
        :label => "testing task3",
        :target_host => "host",
        :check => "ping",
        :periodicity => 60
      })

      p = Dimosir::Peer.create({:ip => "1.1.1.1", :port => 10000})

      job = t.generate_job(p)
      job.task.should eql t
    end

  end


end