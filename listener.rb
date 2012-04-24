require "socket"

class Listener

  include Loggable

  @logger
  @port
  @router
  @server

  def initialize(l, p, r)
    @logger = l
    @port = p
    @router = r
  end

  def start
    @server = TCPServer.open(@port)
    log(SimpleLogger::DEBUG, "Listening on #{@port}")
    loop do
      Thread.new(@server.accept) do |connection|
        log(SimpleLogger::DEBUG, "Accepting connection from: #{connection.peeraddr[2]} on local port #{@port}")

        begin
          # TODO: constant DELIMITER
          data = connection.gets("\0")
          if data != nil
            data.chomp!
            if data[-1] == "\0"
              data.chop!
            end
          end

          log(SimpleLogger::DEBUG, "raw message: #{data}")

          # TODO: begin/rescue block while constructing Peer
          peer = Peer.new_from_json(data.split("|", 2).first)
          msg = data.split("|", 2).last

          @router.consume_message(peer, msg)
        rescue Exception => e
          log(SimpleLogger::ERROR, "Error receiving message\n\tError: #{e.class}\n\tError msg: #{e.message}")
        ensure
          connection.close unless connection.nil?
        end
      end
    end
  end

end
