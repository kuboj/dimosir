require "ipaddress"

class Sender

  @logger

  def initialize(l)
    @logger = l
  end

  def send_msg(ip, port, msg)
    raise ArgumentError "bad IP address" unless IPAddress.valid? ip
    raise ArgumentError "bad port" unless port.is_a? Integer

    socket = nil

    begin
      socket = TCPSocket.new(ip.to_s, port.to_i)
      socket.print(msg) # TODO check retval
    rescue => e

      puts "ERROR: while trying to connect #{ip}:#{port.to_i}"
      puts "ERROR msg: #{e.message}"
      return ""
    ensure
      socket.close unless socket.nil?
    end

    puts "returning #{data}"
    return data
  end

end