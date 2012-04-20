require "mongo_mapper"
require "bson"

MongoMapper.connection = Mongo::Connection.new("127.0.0.1")
MongoMapper.database = "test"
MongoMapper.connection["test"].authenticate("admin", "admin")

class Article
  include MongoMapper::Document

  key :title,        String
  key :content,      String
  key :published_at, Time
  timestamps!
  safe
end

a = Article.create({
  :title => "meh",
  :content => "kvak",
  :published_at => Time.now
})



puts "kvik!"
puts a.id