peers = %w(10000 10001 10002)
me = ARGV[0]

server = Thread.new do
  puts "Begin of sinatra thread ... "

  require "sinatra"
  set :port, me

  get "/" do
    sleep 1
    logger.info("request from #{request.ip}")
    sleep 1
    logger.info(request.body)
    sleep 1
    logger.info("msg: #{params["msg"]}")
    sleep 1
    return "hello, #{request.ip}, I am #{me}"
  end

  puts "End of sinatra thread"
end

client = Thread.new do
  puts "Begin of rest-client thread ... "

  require "rest-client"

  if 10000.to_s != me.to_s then
    puts "server says: #{RestClient.get "http://127.0.0.1:10000/", {:params => {"msg" => "#{me} says hi"}}}"
  else
    sleep 5
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
  puts "End of rest-client thread ... "
end

puts "Running ..."

server.join
client.join