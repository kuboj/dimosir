# TODO: capturing signals in ruby
# TODO: init.d/upstart script
# TODO: communication with daemon - add/del/reload tasks, start/stop/restart
# TODO: new thread checking network connection. if down, then kill itself
# TODO: config file
#               db - host, name, collection, user, password
#               connection - self ip, port
#               log level, log file
#               thread pool - max num of worker threads
# TODO: log file
# TODO: RuntimeError - if cannot connect db ...
# TODO: parameters checking on input
# TODO: use standard Logger instead of custom SimpleLogger

require "rubygems"
require "bundler/setup"
require_relative "loggable"
require_relative "cmd"
require_relative "database_adapter"
require_relative "kernel"
require_relative "election"
require_relative "listener"
require_relative "sender"
require_relative "simple_logger"
require_relative "task"
require_relative "peer"
require_relative "job"
require_relative "task_scheduler"
require_relative "job_generator"
require_relative "job_executor"
require_relative "config"

require_relative "thread_pool"
require_relative "../trollop/trollop"
require_relative "check/abstract_check"
require_relative "check/ping"

module Dimosir

  class Main

    include Loggable

    @opts
    @logger

    def initialize(daemonized, config_file)
      # config
      #$DEBUG = true
      Thread.abort_on_exception = true

      # parse commandline arguments
      #@opts = Cmd.parse_argv
      if config_file == "config/config.yaml"
        config_file = "#{File.expand_path(File.dirname(__FILE__))}/../../config/config.yaml"
      end
      @opts = Config.parse_file(config_file)
      @opts["logging"]["log_file"] = "" if not daemonized
    end

    def run
      # init
      @logger        = SimpleLogger.new(
                        @opts["logging"]["log_level"],
                        %w(sender listener),
                        @opts["logging"]["log_file"]
                      )
      # set signal handlers
      # TODO: to class signal.rb
      Signal.trap("TERM") do
        log(INFO, "Got TERM signal, shutting down ...")
        # TODO: de-register from system, un-assign all tasks, complete currently executed jobs ...
        Process.exit
      end
      Signal.trap("EXIT") do
        log(INFO, "Got EXIT signal, shutting down ...")
        Process.exit
      end

      set_logger(@logger)
      db            = DatabaseAdapter.new(
                        @logger,
                        @opts["database"]["host"],
                        @opts["database"]["port"],
                        @opts["database"]["db_name"],
                        @opts["database"]["user"],
                        @opts["database"]["password"]
                      )
      scheduler     = TaskScheduler.new(@logger)
      peer_self     = db.get_peer(@opts["peer"]["ip"], @opts["peer"]["port"])

      thread_pool   = ThreadPool.new(@logger, @opts["performance"]["thread_pool_size"])
      job_generator = JobGenerator.new(@logger, db, peer_self)
      job_executor  = JobExecutor.new(@logger, db, peer_self, thread_pool)
      sender        = Sender.new(@logger, peer_self)
      election      = Election.new(@logger, db, sender, peer_self)
      kernel        = Kernel.new(@logger, db, sender, peer_self, election,
                                 scheduler, job_generator, job_executor)
      listener      = Listener.new(@logger, @opts["peer"]["port"], kernel)

      lt = Thread.new { listener.start }
      kernel.start
      lt.join

      puts "Exit."
    end

  end

end