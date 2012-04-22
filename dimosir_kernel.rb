class DimosirKernel

  include Loggable

  @peer_self

  @logger
  @db
  @sender

  def initialize(l, d, s, ip, port)
    @logger = l
    @db = d
    @sender = s

    # TODO: check ip and port on input, IPAddr object
    # port has to be integer, > 1000, < 65000

    set_peer_self(ip, port)
  end

  def set_peer_self(ip, port)
    is_in_db = false
    peers = @db.get_peers(:ip => ip, :port => port, :order => :created_at.asc)
    if peers.count == 0
      log(SimpleLogger::DEBUG, "Peer id not in db, adding.")
      @peer_self = @db.add_peer(ip, port)
      log(SimpleLogger::DEBUG, "Peer: #{@peer_self.id}")
    elsif peers.count == 1
      @peer_self = peers[0]
      log(SimpleLogger::DEBUG, "Peer found in db: #{@peer_self.id}")
    else # peers.count > 1
      log(SimpleLogger::WARNING, "Multiple peers with ip #{ip} and port #{port} found. taking first")
      @peer_self = peers[0]
    end
  end

  def get_peer_self
    return @peer_self
  end

  def consume_message(peer_from, msg)
    Thread.new do
      log(SimpleLogger::DEBUG, "Got msg from #{peer_from.ip}:#{peer_from.port} (id: #{peer_from.id}): #{msg}")

    end
  end

end