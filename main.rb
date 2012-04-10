# TODO all classes will extend "LogableModule" -> "self.log" ?
# TODO : is "puts" thread safe ?
# TODO: socket buffering ?

$DEBUG = false
port = ARGV[0]

gem "ipaddress"

require("#{File.expand_path(File.dirname(__FILE__))}/listener")
require("#{File.expand_path(File.dirname(__FILE__))}/input_reader")
require("#{File.expand_path(File.dirname(__FILE__))}/simple_logger")
require("#{File.expand_path(File.dirname(__FILE__))}/message_router")
require("#{File.expand_path(File.dirname(__FILE__))}/sender")
require("#{File.expand_path(File.dirname(__FILE__))}/pool")




# init
logger = SimpleLogger.new("debug")
router = MessageRouter.new(logger)

# start listener
l = Listener.new(logger, port, router)

lt = Thread.new do
  l.start
end

# start sender
s = Sender.new(logger)

peers = [10000, 10001]
peers.each do |peer|
  next if peer.to_s == port.to_s
  msg = "hello!"
  s.send_msg("127.0.0.1", peer, "#{msg}\0")
end

# wait for threads
lt.join
it.join

puts "Exit."