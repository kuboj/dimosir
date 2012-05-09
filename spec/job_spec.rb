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