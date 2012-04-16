# TODO all classes will extend "LoggableModule" -> "self.log" ?
# TODO : is "puts" thread safe ?
# TODO: socket buffering ?
# TODO: .conf parsing
# TODO: capturing signals in ruby
# TODO: init.d/upstart script

$DEBUG = true
$port = ARGV[0] # TODO: check

gem "ipaddress"
gem "mongo"
gem "mongo_mapper"

require("#{File.expand_path(File.dirname(__FILE__))}/db")
require("#{File.expand_path(File.dirname(__FILE__))}/listener")
require("#{File.expand_path(File.dirname(__FILE__))}/input_reader")
require("#{File.expand_path(File.dirname(__FILE__))}/simple_logger")
require("#{File.expand_path(File.dirname(__FILE__))}/dimosir_kernel")
require("#{File.expand_path(File.dirname(__FILE__))}/sender")
require("#{File.expand_path(File.dirname(__FILE__))}/pool")

# init
logger    = SimpleLogger.new("debug")
db        = Db.new(logger)
sender    = Sender.new(logger)

kernel    = DimosirKernel.new(logger, db, sender)
listener  = Listener.new(logger, port, kernel)
reader    = InputReader.new(logger, sender)

# start listener
lt = Thread.new do
  listener.start
end

# start input reader
rt = Thread.new do
  reader.start
end

# wait for threads
lt.join
it.join
rt.join

puts "Exit."