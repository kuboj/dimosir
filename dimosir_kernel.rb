class DimosirKernel

  include Loggable

  @peer_self

  @logger
  @db
  @sender

  def initialize(l, d, s, p)
    @logger = l
    @db = d
    @sender = s
    @peer_self = p
  end

  def get_peer_self
    return @peer_self
  end

  def consume_message(peer_from, msg)
    Thread.new do
      log(SimpleLogger::DEBUG, "Got msg from #{peer_from.ip}:#{peer_from.port} (id: #{peer_from.id}): #{msg}")
      if msg == "s"
        start_election
      end

      # if msg == Election::MSG_INQUIRY
      # if @peer.self.id > peer_from.id -> chod do prdele
      # if @peer.self.if < peer_from.id -> cakam.
      # end

    end
  end

  def start_election
    peers = @db.get_peers({})
    peers.each do |peer|
      #@sender.send_msg(@peer_self, ) if peer < @peer_self
      # send inquiry msg
    end

  end

end