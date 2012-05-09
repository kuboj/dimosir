RSpec.configure do |config|

  config.before(:suite) do
    MongoMapper.connection = Mongo::Connection.new("127.0.0.1")
    MongoMapper.database = "rspec"
    MongoMapper.connection["rspec"].authenticate("rspec", "rspec")
    Dimosir::Job.delete_all
    Dimosir::Peer.delete_all
    Dimosir::Task.delete_all
  end

end