require "spec_helper"

describe Dimosir::Task do

  before :all do
    MongoMapper.connection = Mongo::Connection.new("127.0.0.1")
    MongoMapper.database = "rspec"
    MongoMapper.connection["rspec"].authenticate("rspec", "rspec")
    tasks = Dimosir::Task.all
    tasks.each { |t| t.destroy } unless tasks.nil?
  end

  describe "#new" do

    it "creates new empty task" do
      t = Dimosir::Task.new({
                                :label => "testing task",
                                :target_host => "host",
                                :check => "ping"
                            })
      t.should be_instance_of Dimosir::Task
      t.save.should eql true
      t.
    end

    it "won't create task with missing fields" do
      t = Dimosir::Task.new({:label => "test"})
      t.save.should eql false
    end

  end

end