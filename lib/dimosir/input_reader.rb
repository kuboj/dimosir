module Dimosir

  class InputReader

    include Loggable

    @sender

    def initialize(l, s)
      set_logger(l)

      @sender = s
    end

    def start
      loop do
        port = STDIN.gets.chomp.to_i
        msg = STDIN.gets.chomp
        log(SimpleLogger::DEBUG, "Got on input: #{port}, #{msg}")
        @sender.send_msg(Peer.new(:ip => "127.0.0.1", :port => port), msg)
      end
    end

  end

end