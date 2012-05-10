require "pathname"

module Dimosir

  class Cmd

    def self.parse_argv
      opts = Trollop::options do
        version "Dimosir 0.1 uberbeta (c) 2012 Jakub Jursa" # TODO
        banner <<-EOS
  Distributed monitoring system in Ruby.

  Usage: dimosir [options]

        EOS

        opt :config_file, "Absolute path to config file", :type => :string, :default => "config/config.yaml"
      end

      return opts
    end

  end

end