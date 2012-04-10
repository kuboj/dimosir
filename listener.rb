require "socket"

class Listener

  @logger
  @port
  @server

  def initialize(port, l)
    @port = port
    @logger = l
  end

  def start
    @server = TCPServer.open(@port)
    loop do
      Thread.new(@server.accept) do |connection|

        puts "Accepting connection from: #{connection.peeraddr[2]}"

        begin
          data = connection.gets("\0")
          if data != nil
            data = data.chomp
          end

          puts "Incoming: #{data}"
          puts "Simulating work ..."
          sleep 5
          puts "Work done."

          connection.print("You said: #{data}\0")
          connection.flush
        rescue Exception => e
          puts "#{e} (#{ e.class })"
        ensure
          connection.close
          puts "ensure: Closing"
        end
      end
    end
  end

end
