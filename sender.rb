require "ipaddress"

class Sender

  @logger

  def initialize(l)
    @logger = l
  end

  # TODO: parameters-> Peer, String ?
  def send_msg(peer_from, peer_to, msg)
    # TODO: check if peer_from and peer_to are instance of Peer
    log("debug", "#{peer_from.ip}:#{peer_from.port} trying to send msg '#{msg}' to #{peer_to.ip}:#{peer_to.port}")

    socket = nil
    no_error = true

    begin
      socket = TCPSocket.new(peer_to.ip.to_s, peer_to.port.to_i)
      socket.print("#{peer_from.to_json}|#{msg}\0")
    rescue => e
      # TODO: substitute for constant @see SimpleLogger
      log("error", "Error sending message.\n\terror msg: #{e.message}")
      no_error = false
    ensure
      socket.close unless socket.nil?
    end

    log("debug", "Message sent: #{no_error}")
    no_error
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end