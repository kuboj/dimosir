require "spec_helper"

describe Dimosir::DatabaseAdapter do

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

      stats = Dimosir::DatabaseAdapter.get_job_stats
      stats1 = stats.select { |s| s["value"]["task_label"] == "task1" }.first
      stats2 = stats.select { |s| s["value"]["task_label"] == "task2" }.first
      stats3 = stats.select { |s| s["value"]["task_label"] == "task3" }.first

      stats1["value"]["successful"].should eql 2
      stats1["value"]["unsuccessful"].should eql 7
      stats3["value"]["successful"].should eql 1
      stats3["value"]["unsuccessful"].should eql 1
    end

  end

end