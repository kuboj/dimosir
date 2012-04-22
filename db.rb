require "mongo_mapper"
require "bson"

class Db

  @logger

  # TODO: db config on input (saved in /etc/dmsir.conf)
  def initialize(l)
    @logger = l

    # TODO: ext. parameters
    MongoMapper.connection = Mongo::Connection.new("127.0.0.1")
    MongoMapper.database = "test"
    MongoMapper.connection["test"].authenticate("admin", "admin")
  end

  def get_peers(criteria)
    return Peer.all(criteria)
  end

  def add_peer(ip, port)
    p = Peer.create!("ip" => ip, "port" => port)
    return p
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end