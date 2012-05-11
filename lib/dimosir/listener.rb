require "socket"

module Dimosir

  class Listener

    include Loggable

    @port
    @router
    @server

    DELIMITER = "\0"

    def initialize(l, p, r)
      set_logger(l)

      @port = p
      @router = r
    end

    def start
      @server = TCPServer.open(@port)
      log(INFO, "Listening on #@port")
      loop do
        Thread.new(@server.accept) do |connection|
          log(DEBUG, "Accepting connection from: #{connection.peeraddr[2]} on local port #@port")

          begin
            data = connection.gets(DELIMITER)
            unless data.nil?
              data.chomp! # removes \n \r ...
              data.chop! if data[-1] == DELIMITER # removes last character
            end

            log(DEBUG, "raw message: #{data}")

            peer = Peer.new_from_json(data.split("|", 2).first)
            msg = data.split("|", 2).last

            @router.consume_message(peer, msg)
          rescue Exception => e
            log(ERROR, "Error receiving message\n\tError: #{e.class}\n\tError msg: #{e.message}")
          ensure
            connection.close unless connection.nil?
          end
        end
      end
    end

  end

end