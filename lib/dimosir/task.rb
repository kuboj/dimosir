require "mongo_mapper"
require "bson"

module Dimosir

  class Task

    include MongoMapper::Document
    include Loggable

    set_collection_name "tasks"

    key :script,    String, :required => true
    key :label,     String, :required => true
    key :arguments, String, :default => ""

    safe
    timestamps!

  end

end