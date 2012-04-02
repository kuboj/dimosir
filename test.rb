peers = %w(10000 10001 10002)
me = ARGV[0]

server = Thread.new do
  require "sinatra"
  set :port, me

  get "/" do
    logger.info("request from #{request.ip}")
    logger.info(request.body)
    logger.info("msg: #{params["msg"]}")
    return "hello, #{request.ip}, I am #{me}"
  end
end

client = Thread.new do
  require "rest-client"

  if 10000.to_s != me.to_s then
    puts "server says: #{RestClient.get "http://127.0.0.1:10000/", {:params => {"msg" => "#{me} says hi"}}}"
  end
#  peers.each do |peer|
 #   next if peer == me
  #  begin
   #   puts "http/127.0.0.1:#{peer}/"
    #  puts RestClient.get "http/127.0.0.1:#{peer}/", {:params => {"msg" => "#{me} says hi"}}
   # rescue => e
    #  puts e.message
    #end
  #end

end

puts "Running ..."

server.join
client.join