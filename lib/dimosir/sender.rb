require "ipaddress"

module Dimosir

  class Sender

    include Loggable

    @logger
    @peer_sender

    def initialize(l, p)
      # TODO: parameters

      @logger = l
      @peer_sender = p
    end

    # TODO: parameters-> Peer, String ?
    def send_msg(peer_to, msg)
      log(DEBUG, "#{@peer_sender.info} trying to send msg '#{msg}' to #{peer_to.info}")

      socket = nil
      no_error = true

      begin
        socket = TCPSocket.new(peer_to.ip.to_s, peer_to.port.to_i)
        socket.print("#{@peer_sender.to_json}|#{msg}\0")
      rescue => e
        # TODO: substitute for constant @see SimpleLogger
        log(ERROR, "Error sending message.\n\terror msg: #{e.message}")
        no_error = false
      ensure
        socket.close unless socket.nil?
      end

      log(DEBUG, "Message sent: #{no_error}")

      no_error
    end

  end

end