#!/usr/bin/env ruby

# TODO: Gemfile
# TODO: capturing signals in ruby
# TODO: init.d/upstart script
# TODO: daemonize

# config
#$DEBUG = true
Thread.abort_on_exception = true

# load
require("#{File.expand_path(File.dirname(__FILE__))}/loggable")
require("#{File.expand_path(File.dirname(__FILE__))}/cmd")
require("#{File.expand_path(File.dirname(__FILE__))}/peer")
require("#{File.expand_path(File.dirname(__FILE__))}/db")
require("#{File.expand_path(File.dirname(__FILE__))}/listener")
require("#{File.expand_path(File.dirname(__FILE__))}/input_reader")
require("#{File.expand_path(File.dirname(__FILE__))}/simple_logger")
require("#{File.expand_path(File.dirname(__FILE__))}/dimosir_kernel")
require("#{File.expand_path(File.dirname(__FILE__))}/sender")
require("#{File.expand_path(File.dirname(__FILE__))}/pool")
require("#{File.expand_path(File.dirname(__FILE__))}/lib/trollop")
require "pathname"

# parse commandline arguments
opts = Cmd.parse_argv

# init
logger    = SimpleLogger.new(opts[:log_level])
db        = Db.new(logger)
sender    = Sender.new(logger)
kernel    = DimosirKernel.new(logger, db, sender, opts[:ip], opts[:port])
listener  = Listener.new(logger, opts[:port], kernel)
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
rt.join

puts "Exit."