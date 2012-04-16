require "mongo"
require "mongoid"

Mongoid.database = Mongo::Connection.new("127.0.0.1").db("test")
Mongoid.database.authenticate("admin", "admin")

Mongoid.logger = Logger.new($stdout)

class Person
  include Mongoid::Document
  store_in :citizens

  field :first_name, type: String
  field :middle_name, type: String
  field :last_name, type: String
end

john = Person.new({
  :first_name => "John",
  :middle_nam => "john2",
  :last_name => "Smith"
  }
)

puts "saved? #{john.save!}"

=begin
require "mongo"

connection = Mongo::Connection.new("localhost", 27017)
#auth = db.authenticate("admin", my_password)
connection.database_names
connection.database_info.each { |info| puts info.inspect }
=end
