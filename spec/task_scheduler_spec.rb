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

    @db.stub(:get_all_tasks) { [@t1, @t2, @t3] }
    @db.stub(:get_all_peers) { [@p1, @p2] }

    @ts = Dimosir::TaskScheduler.new(@logger, @db)
  end

  describe "#new" do

    it "takes two arguments" do
      ts = Dimosir::TaskScheduler.new(@logger, @db)
      ts.should be_instance_of Dimosir::TaskScheduler
    end

  end

  describe "#reschedule_all" do

    it "assigns each task to some peer" do
      @ts.reschedule_all
      @t1.peer.should_not eql nil
      @t2.peer.should_not eql nil
      @t3.peer.should_not eql nil
    end

  end

end