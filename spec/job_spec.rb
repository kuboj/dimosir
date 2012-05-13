require "spec_helper"

describe Dimosir::Job do

  before(:each) do
    @task = Dimosir::Task.new({
      :label => "testing",
      :target_host => "localhost",
      :check => "ping",
      :periodicity => 10
    })

    @job = Dimosir::Job.create({
      :task_label => "testing",
      :task => @task
    })
    @task.reload
  end

  after(:each) do
    @task.destroy
    @task.destroy
  end

  describe "::check_exists" do

    it "checks that 'ping' exists" do
      Dimosir::Job.check_exists("ping").should be_true
    end

    it "checks that 'nonexisting' doesn't exists" do
      Dimosir::Job.check_exists("nonexisting").should be_false
    end

  end

  describe "::get_stats" do

    it "inserts some values and mapreduce runs correctly" do
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 1})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 1})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 1})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 2})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 2})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 2})
      Dimosir::Job.create({:task_id => 1, :task_label => "task1", :done => true, :exitstatus => 3})

      Dimosir::Job.create({:task_id => 2, :task_label => "task2", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 2, :task_label => "task2", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 2, :task_label => "task2", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 2, :task_label => "task2", :done => true, :exitstatus => 1})
      Dimosir::Job.create({:task_id => 2, :task_label => "task2", :done => true, :exitstatus => 1})

      Dimosir::Job.create({:task_id => 3, :task_label => "task3", :done => true, :exitstatus => 0})
      Dimosir::Job.create({:task_id => 3, :task_label => "task3", :done => true, :exitstatus => 1})
      Dimosir::Job.create({:task_id => 3, :task_label => "task3", :done => false, :exitstatus => nil})
      Dimosir::Job.create({:task_id => 3, :task_label => "task3", :done => false, :exitstatus => nil})

      stats = Dimosir::Job.get_stats
      stats1 = stats.select { |s| s["value"]["task_label"] == "task1" }.first
      stats2 = stats.select { |s| s["value"]["task_label"] == "task2" }.first
      stats3 = stats.select { |s| s["value"]["task_label"] == "task3" }.first

      stats1["value"]["successful"].should eql 2
      stats1["value"]["unsuccessful"].should eql 7
      stats3["value"]["successful"].should eql 1
      stats3["value"]["unsuccessful"].should eql 1
    end

  end

  describe "#run" do

    it "shouldn't raise exception if 'check' exists" do
      lambda { @job.run }.should_not raise_error
    end

    it "should raise exception if 'check' doesn't exist" do
      @task.check = "nonexistingcheck"
      @task.save
      @task.reload

      lambda { @job.run }.should raise_error(LoadError)
    end

    it "runs job and saves to db output and exitstatus" do
      @job.run
      @job.done.should be_true
      @job.exitstatus.should eql 0
    end

  end

end