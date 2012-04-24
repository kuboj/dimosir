require "mongo_mapper"
require "bson"

class Db

  include Loggable

  @logger

  # TODO: db config on input (saved in /etc/dmsir.conf)
  def initialize(l)
    @logger = l

    # TODO: ext. parameters - from config file / input ...
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

  def get_peer(ip, port)
    is_in_db = false
    peers = get_peers(:ip => ip, :port => port, :order => :created_at.asc)
    peer_self = nil

    if peers.count == 0
      log(SimpleLogger::DEBUG, "Peer id not in db, adding.")
      peer_self = add_peer(ip, port)
      log(SimpleLogger::DEBUG, "Peer: #{peer_self.id}")
    elsif peers.count == 1
      peer_self = peers[0]
      log(SimpleLogger::DEBUG, "Peer found in db: #{peer_self.id}")
    else # peers.count > 1
      log(SimpleLogger::WARNING, "Multiple peers with ip #{ip} and port #{port} found. taking first")
      peer_self = peers[0]
    end

    return peer_self
  end

  #def get_higher_peers(peer)
  #  return get_peers(:id.gt => @peer_self.id)
  #end

end