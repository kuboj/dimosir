require "mongo_mapper"
require "bson"

module Dimosir

  class DatabaseAdapter

    include Loggable

    def initialize(l)
      set_logger(l)

      # TODO: ext. parameters - from config file / input ...
      begin
        MongoMapper.connection = Mongo::Connection.new("1127.0.0.1")
        MongoMapper.database = "test"
        MongoMapper.connection["test"].authenticate("admin", "admin")
      rescue => e
        log(ERROR, "Error connecting to mongo. Error msg: #{e.message}")
        raise RuntimeError
      end
    end

    def get_all_peers
      Peer.all
    end

    def get_higher_peers(peer_self)
      peers = get_other_peers(peer_self)
      peers.select! { |peer| peer > peer_self } # leave higher peers only
      return peers
    end

    def get_other_peers(peer_self)
      Peer.all(:id => {:$ne => peer_self.id})
    end

    def add_peer(ip, port)
      Peer.create!("ip" => ip, "port" => port)
    end

    def get_peer(ip, port)
      is_in_db = false
      peers = Peer.all(:ip => ip, :port => port, :order => :created_at.asc)
      peer_self = nil

      if peers.count == 0
        log(DEBUG, "Peer id not in db, adding.")
        peer_self = add_peer(ip, port)
        log(DEBUG, "Peer: #{peer_self.id}")
      elsif peers.count == 1
        peer_self = peers[0]
        log(DEBUG, "Peer found in db: #{peer_self.id}")
      else # peers.count > 1
        log(WARNING, "Multiple peers with ip #{ip} and port #{port} found. taking first")
        peer_self = peers[0]
      end

      peer_self
    end

    def del_peer(peer)
      log(DEBUG, "Removing #{peer.info} from db")
      peer.delete
    end

  end

end