require "ipaddress"

module Dimosir

  class Sender

    include Loggable

    @peer_sender

    DELIMITER = "\0"

    def initialize(l, p)
      set_logger(l)

      @peer_sender = p
    end

    def send_msg(peer_to, msg)
      log(DEBUG, "#{@peer_sender.info} trying to send msg '#{msg}' to #{peer_to.info}")

      socket = nil
      no_error = true

      begin
        socket = TCPSocket.new(peer_to.ip.to_s, peer_to.port.to_i)
        socket.print("#{@peer_sender.to_json}|#{msg}#{DELIMITER}")
      rescue => e
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