require "mongo"
require "mongoid"

class Peer
  incude Mongoid::Document
  store_in :peers

  field :ip, type: String
  field :port, type: Integer
end

class Db

  @logger

  # TODO: db config on input (saved in /etc/dmsir.conf)
  def initialize(l)
    @logger = l

    # TODO: ext. parameters
    Mongoid.database = Mongo::Connection.new("127.0.0.1").db("test")
    Mongoid.database.authenticate("admin", "admin")
    Mongoid.logger = Logger.new($stdout)
  end

  def get_peers()
    return Peers.all_in
=begin
    peers = [
          Hash[:id => 1, :port => 10000, :ip => "127.0.0.1"],
          Hash[:id => 2, :port => 10001, :ip => "127.0.0.1"],
          Hash[:id => 3, :port => 10002, :ip => "127.0.0.1"]
    ]
    log("debug", "get_peers: #{peers.to_s}")
    return peers
=end
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end