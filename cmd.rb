require "pathname"

class Cmd

  def self.parse_argv
    opts = Trollop::options do
      version "main 0.1 uberbeta (c) 2012 Jakub Jursa" # TODO
      banner <<-EOS
Distributed monitoring system in ruby.

Usage: main.rb [options]

      EOS

      opt :ip, "Local IP", :type => :string
      opt :port, "Local port to listen on", :type => :int
      opt :log_level, SimpleLogger.get_log_levels_str, :type => :int, :default => SimpleLogger::ERROR
    end

    Trollop::die :ip, "IP has to be set" if !opts[:ip]
    Trollop::die :port, "port has to be set" if !opts[:port]
    Trollop::die :log_level, "Log level has to be in #{SimpleLogger.get_log_level_values.to_s}" \
      if !SimpleLogger.get_log_level_values.include?(opts[:log_level])

    return opts
  end

end