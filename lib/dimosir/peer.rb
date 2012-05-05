require "mongo_mapper"
require "bson"

module Dimosir

  class Peer

    include MongoMapper::Document

    set_collection_name "peers"

    key :ip,    String,   :required => true
    key :port,  Integer,  :required => true

    safe
    timestamps!

    def self.new_from_json(json)
      hash = nil
      begin
        hash = JSON.parse(json)
      rescue JSON::ParserError => e
        raise ArgumentError, "Invalid json - #{json}"
      end

      if hash.has_key?("port") && hash.has_key?("ip") && hash.has_key?("id")
        return Peer.new(hash)
      else
        raise ArgumentError, "Invalid json, values missing - #{json}"
      end
    end

    def info
      "[#{ip}:#{port} #{id}]"
    end

    def <(peer)
      id.to_s < peer.id.to_s
    end

    def >(peer)
      id.to_s > peer.id.to_s
    end

    def ==(peer)
      id.to_s == peer.id.to_s
    end

  end

end