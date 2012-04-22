require "mongo_mapper"
require "bson"

class Peer
  include MongoMapper::Document

  set_collection_name "peers"

  key :ip,    String
  key :port,  Integer

  safe
  timestamps!

  def self.from_json(json)
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

end