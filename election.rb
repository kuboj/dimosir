#require "/home/bubo/RubymineProjects/bac1/server"

puts "**"
puts File.expand_path(File.dirname(__FILE__))

require "#{File.expand_path(File.dirname(__FILE__))}/server"


=begin
def get_peers
  %w("127.0.0.1:10000" "127.0.0.1:10001" "127.0.0.1:10002")
end

puts "-------"
begin
  puts RestClient.get 'http://localhost:11111/'
rescue => e
  puts e.message
end
puts "-------"

get "/" do
  "Hello world!"
end

get "/election/new/:sender_id" do
  logger.info("kvik")
  "o'hai, #{params[:sender_id]}!"
end

Thread.new do
  while true do
    puts "kvik"
    sleep 2
  end
end

=end

Server.run!