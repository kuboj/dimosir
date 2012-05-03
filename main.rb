#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

# TODO: capturing signals in ruby
# TODO: init.d/upstart script
# TODO: daemonize
# TODO: thread checking network connection. if down, then kill itself

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
require("#{File.expand_path(File.dirname(__FILE__))}/election")

require("#{File.expand_path(File.dirname(__FILE__))}/lib/trollop")

# parse commandline arguments
opts = Cmd.parse_argv

# init
logger    = SimpleLogger.new(opts[:log_level], %w(sender))
db        = Db.new(logger)

peer_self = db.get_peer(opts[:ip], opts[:port])

sender    = Sender.new(logger, peer_self)
election  = Election.new(logger, db, sender, peer_self)
kernel    = DimosirKernel.new(logger, db, sender, peer_self, election)
listener  = Listener.new(logger, opts[:port], kernel)
reader    = InputReader.new(logger, sender)

# start listener
lt = Thread.new do
  listener.start
end

# start input reader
rt = Thread.new do
  reader.start
end

kernel.start

# wait for threads
lt.join
rt.join

puts "Exit."