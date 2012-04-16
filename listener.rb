require "socket"

class Listener

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
    log("debug", "Listening on #{@port}")
    loop do
      Thread.new(@server.accept) do |connection|
        log("debug", "Accepting connection from: #{connection.peeraddr[2]} on local port #{@port}")

        begin
          # TODO: constant DELIMITER
          data = connection.gets("\0")
          if data != nil
            data.chomp!
            if data[-1] == "\0"
              data.chop!
            end
          end

          @router.consume_message(data)
        rescue Exception => e
          log("error", "Error receiving message\n\tError: #{e.class}\n\tError msg: #{e.message}")
          # TODO wtf is puts "#{e}" ?
        ensure
          connection.close
        end
      end
    end
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end
