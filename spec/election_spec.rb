require "spec_helper"
require "rspec/mocks"

describe Election do

  before :each do
    @logger = double("logger")
    @db = double("logger")
    @sender = double("sender")
    @peer_self = double("peer_self")
    @election = Election.new(@logger, @db, @sender, @peer_self)
  end

  describe "#new" do

    it "takes 4 parameters" do
      logger = double("logger")
      db = double("logger")
      sender = double("sender")
      peer_self = double("peer_self")
      election = Election.new(logger, db, sender, peer_self)
    end

  end

  describe "#msg_election" do

    it "is called dynamically" do
      peer_from = double("peer")
      peer_from.stub(:info => "mocked peer_from")

      @election.should_receive(:msg_election).once

      @election.send(Election::MSG_ELECTION.split(".").last, peer_from)
    end

    it "logs received message" do
      peer_from = double("peer")
      peer_from.stub(:info => "mocked peer_from")

      @logger.should_receive(:llog).once

      @election.msg_election(peer_from)
    end

  end


end