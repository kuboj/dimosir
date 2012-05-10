require "spec_helper"

describe Dimosir::ThreadPool do

  before(:each) do
    logger = double("logger")
    logger.stub(:llog => "logged ...")
    size = 5

    @pool = Dimosir::ThreadPool.new(logger, size)
  end

  describe "#new" do

    it "takes two parameters" do
      logger = double("logger")
      size = 10

      tp = Dimosir::ThreadPool.new(logger, size)
      tp.should be_instance_of Dimosir::ThreadPool
    end

  end

  describe "#schedule" do

    it "schedules single job and executes it" do
      job = double("job")
      job.should_receive(:run).once
      p = Proc.new { |j| j.run }
      @pool.schedule(job, p)
      @pool.shutdown
    end

    it "schedules 100 jobs and waits until done" do
      100.times do |i|
        job = double("job")
        job.stub(:i => i)
        job.should_receive(:run).once
        p = Proc.new { |j| j.run }
        @pool.schedule(job, p)
      end
      @pool.shutdown
    end

  end

end