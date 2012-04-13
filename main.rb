# TODO all classes will extend "LogableModule" -> "self.log" ?
# TODO : is "puts" thread safe ?
# TODO: socket buffering ?

$DEBUG = true
port = ARGV[0] # TODO: check

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
listener = Listener.new(logger, port, router)

lt = Thread.new do
  listener.start
end

# start sender
sender = Sender.new(logger)

# start input reader
reader = InputReader.new(logger, sender)
rt = Thread.new do
  reader.start
end

# wait for threads
lt.join
it.join

puts "Exit."