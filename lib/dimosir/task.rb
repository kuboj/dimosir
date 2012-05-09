require "mongo_mapper"
require "bson"

module Dimosir

  class Task

    include MongoMapper::Document

    set_collection_name "checks"

    key :label,       String, :required => true
    key :target_host, String, :required => true
    key :check,       String, :required => true
    key :arguments,   Hash,   :default => {}
    belongs_to :peer
    key :peer_id,     ObjectId

    safe
    timestamps!

  end

end