# TODO: capturing signals in ruby
# TODO: init.d/upstart script
# TODO: daemonize
# TODO: communication with daemon - add/del/reload tasks, start/stop/restart
# TODO: new thread checking network connection. if down, then kill itself
# TODO: config file
#               db - host, name, collection, user, password
#               connection - self ip, port
#               log level, log file
#               thread pool - max num of worker threads
# TODO: log file
# TODO: RuntimeError - if cannot connect db ...

require "rubygems"
require "bundler/setup"
require_relative "loggable"
require_relative "cmd"
require_relative "db"
require_relative "kernel"
require_relative "election"
require_relative "input_reader"
require_relative "listener"
require_relative "peer"
require_relative "sender"
require_relative "simple_logger"
require_relative "task"
require_relative "thread_pool"
require_relative "../trollop/trollop"

module Dimosir

  class Main

    def initialize
      # config
      #$DEBUG = true
      Thread.abort_on_exception = true
    end

    def run
      # parse commandline arguments
      opts      = Cmd.parse_argv

      # init
      logger    = SimpleLogger.new(opts[:log_level], %w(sender listener))
      db        = DatabaseAdapter.new(logger)

      peer_self = db.get_peer(opts[:ip], opts[:port])

      sender    = Sender.new(logger, peer_self)
      election  = Election.new(logger, db, sender, peer_self)
      kernel    = Kernel.new(logger, db, sender, peer_self, election)
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
    end

  end

end