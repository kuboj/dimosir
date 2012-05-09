require "spec_helper"

describe Dimosir::Peer do

  before :all do
    MongoMapper.connection = Mongo::Connection.new("127.0.0.1")
    MongoMapper.database = "rspec"
    MongoMapper.connection["rspec"].authenticate("rspec", "rspec")
    peers = Dimosir::Peer.all
    peers.each { |p| p.destroy } unless peers.nil?

    tasks = Dimosir::Task.all
    tasks.each { |t| t.destroy } unless tasks.nil?
  end

  describe "#new" do

    it "creates new empty peer" do
      p = Dimosir::Peer.new
      p.should be_instance_of Dimosir::Peer
    end

    it "cannot save peer without ip or port given" do
      p = Dimosir::Peer.new(:ip => "172.168.86.1")
      p.save.should eql false
    end

    it "creates new peer from given parameters" do
      ip = "172.168.86.1"
      port = 10000
      id = "kviiik?"
      p = Dimosir::Peer.new(:ip => ip, :port => port, :id => id)

      p.ip.should eql ip
      p.port.should eql port
      p.id.to_s.should eql id
    end

    it "creates peer correctly" do
      p = Dimosir::Peer.new(:ip => "172.168.86.1", :port => 10000)
      p.save.should eql true
    end

  end

  describe "::new_from_json" do

    it "cannot create object from malformed json" do
      lambda { p = Dimosir::Peer.new_from_json("") }.should raise_exception ArgumentError
    end

  end

  describe "#<" do

    it "evaluates peer1 to be less than peer2 if peer1 was created sooner" do
      (Dimosir::Peer.new() < Dimosir::Peer.new()).should be_true
    end

  end

  describe "#>" do

    it "evaluates peer1 with id 2 to be more than peer 2 with id 1" do
      (Dimosir::Peer.new(:id => 2) > Dimosir::Peer.new(:id => 1)).should be_true
    end

  end

  describe "#==" do

    it "compares two peers for equality" do
      p1 = Dimosir::Peer.new(:ip => "1.1.1.1", :port => 10000, :id => "1")
      p2 = Dimosir::Peer.new(:ip => "1.1.1.2", :port => 20000, :id => "1")
      (p1 == p2).should be_true
    end

    it "compares two peers for inequality" do
      p1 = Dimosir::Peer.new(:ip => "1.1.1.1", :port => 10000, :id => "1")
      p2 = Dimosir::Peer.new(:ip => "1.1.1.2", :port => 20000, :id => "2")
      (p1 != p2).should be_true
    end

  end

  describe "#info" do

    it "returns formatted address and id of peer" do
      ip = "172.168.86.1"
      port = 10000
      p = Dimosir::Peer.new(:ip => ip, :port => port)

      p.info.should eql "[#{ip}:#{port} #{p.id.to_s}]"
    end

  end

  describe "#get_tasks" do

    it "returns no tasks" do
      ip = "172.168.86.1"
      port = 10000
      p = Dimosir::Peer.new(:ip => ip, :port => port)
      p.save
      p.tasks.size.should eql 0
    end

    it "returns 1 newly created tasks" do
      ip = "172.168.86.1"
      port = 10000
      p = Dimosir::Peer.create(:ip => ip, :port => port)
      t1 = Dimosir::Task.create(
        :label => "task1",
        :target_host => "localhost",
        :check => "ping",
        :peer => p,
        :periodicity => 10
      )

      p.tasks[0].should eql t1
    end

  end

end
