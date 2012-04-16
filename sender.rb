require "ipaddress"

class Sender

  @logger

  def initialize(l)
    @logger = l
  end

  # TODO: parameters-> Peer, String ?
  def send_msg(ip, port, msg)
    log("debug", "Trying to send msg '#{msg}' to #{ip}:#{port}")

    raise ArgumentError "bad IP address" unless IPAddress.valid? ip
    raise ArgumentError "bad port" unless port.is_a? Integer

    socket = nil
    no_error = true

    begin
      socket = TCPSocket.new(ip.to_s, port.to_i)
      socket.print("#{msg}\0")
    rescue => e
      # TODO: substitute for constant @see SimpleLogger
      log("error", "Error sending message.\n\tmsg: #{msg}\n\tto: #{ip}:#{port}\n\terror msg: #{e.message}")
      no_error = false
    ensure
      #socket.close unless socket.nil?
    end

    log("debug", "Message sent: #{no_error}")
    no_error
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end