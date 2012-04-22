# TODO : is "puts" thread safe ?
# TODO: socket buffering ?
# TODO: .conf parsing
# TODO: capturing signals in ruby
# TODO: init.d/upstart script

#$DEBUG = true
Thread.abort_on_exception = true
#ip = ARGV[0]
#port = ARGV[1] # TODO: check

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
require "trollop"
require "pathname"

opts = Trollop::options do
  version "test 1.2.3 (c) 2012 blabla" # TODO
  banner <<-EOS
Test is an awesome program that does something very, very important.

Usage: #{__FILE__} [options]

EOS

  opt :ip, "Local IP", :type => :string
  opt :port, "Local port to listen on", :type => :int
  opt :log_level, SimpleLogger.get_log_levels_str, :type => :int, :default => SimpleLogger::ERROR
end

Trollop::die :ip, "IP has to be set" if !opts[:ip]
Trollop::die :port, "port has to be set" if !opts[:ip]
Trollop::die :log_level, "Log level has to be in #{SimpleLogger.get_log_level_values.to_s}" \
  if !SimpleLogger.get_log_level_values.include?(opts[:log_level])

# init
logger    = SimpleLogger.new(opts[:log_level])
db        = Db.new(logger)
sender    = Sender.new(logger)

kernel    = DimosirKernel.new(logger, db, sender, opts[:ip], Integer(opts[:port]))
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