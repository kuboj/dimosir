# TODO mixin, module "Loggable" -> "log" ?
# TODO : is "puts" thread safe ?
# TODO: socket buffering ?
# TODO: .conf parsing
# TODO: capturing signals in ruby
# TODO: init.d/upstart script

#$DEBUG = true
Thread.abort_on_exception = true
ip = ARGV[0]
port = ARGV[1] # TODO: check

gem "bson"
gem "bson_ext"
gem "fast_xs"
gem "ipaddress"
gem "mongo"
gem "mongo_mapper"

require("#{File.expand_path(File.dirname(__FILE__))}/loggable")
require("#{File.expand_path(File.dirname(__FILE__))}/peer")
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

kernel    = DimosirKernel.new(logger, db, sender, ip, Integer(port))
listener  = Listener.new(logger, kernel.get_peer_self.port, kernel)
reader    = InputReader.new(logger, sender, kernel.get_peer_self)

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