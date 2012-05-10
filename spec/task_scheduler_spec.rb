require "spec_helper"

describe Dimosir::TaskScheduler do

  before(:each) do
    @logger = double("logger")
    @logger.stub(:llog => "logged ...")
    @db = double("db")

    @t1 = Dimosir::Task.new(
      :label => "t1",
      :target_host => "localhost",
      :check => "ping",
      :periodicity => "10"
    )
    @t2 = Dimosir::Task.new(
      :label => "t2",
      :target_host => "google.com",
      :check => "ping",
      :periodicity => "20"
    )
    @t3 = Dimosir::Task.new(
      :label => "t3",
      :target_host => "localhost",
      :check => "ping",
      :periodicity => "30"
    )

    @p1 = Dimosir::Peer.new(
      :ip => "127.0.0.1",
      :port => "10000"
    )

    @p2 = Dimosir::Peer.new(
        :ip => "127.0.0.1",
        :port => "10001"
    )

    @ts = Dimosir::TaskScheduler.new(@logger)
  end

  describe "#new" do

    it "takes two arguments" do
      ts = Dimosir::TaskScheduler.new(@logger)
      ts.should be_instance_of Dimosir::TaskScheduler
    end

  end

  describe "#reschedule_all" do

    it "assigns each task to some peer" do
      @ts.reschedule([@p1, @p2], [@t1, @t2, @t3])
      @t1.peer.should_not eql nil
      @t2.peer.should_not eql nil
      @t3.peer.should_not eql nil
    end

  end

end