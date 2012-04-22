class DimosirKernel

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
      log("debug", "peer id not in db, adding.")
      @peer_self = @db.add_peer(ip, port)
      log("debug", "peer: #{@peer_self.id}")
    elsif peers.count == 1
      @peer_self = peers[0]
      log("debug", "peer found in db: #{@peer_self.id}")
    else # peers.count > 1
      log("warning", "multiple peers with ip #{ip} and port #{port} found. taking first")
      @peer_self = peers[0]
    end
  end

  def get_peer_self
    return @peer_self
  end

  def consume_message(peer_from, msg)
    Thread.new do
      log("debug", "Got msg from #{peer_from.ip}:#{peer_from.port} (id: #{peer_from.id}): #{msg}")

      if msg == "start"
        log("debug", "start election")
        election
      end

      if msg == "Election"
        log("debug", "election")
        election
      end

      if msg == "OK"
        log("debug", "ok")
        ok
      end

      if msg == "Coordinator"
        log("debug", "coordinator")
        coordinator
      end
    end
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

  def start_election
    @new_election = true
    @ok_received = false

    peers = db.get_peers()
    my_id = -1
    peers.each do |peer|
      if peer[:port] == $port
        my_id = peer[:id]
      end
    end

    peers.each do |peer|
      if peer[:id] > my_id
        @sender.send_msg(peer[:ip], peer[:port], "Election")
      end
    end

    sleep(5)

    unless @ok_received
      peers.each do |peer|
        if peer[:id] < my_id
          @sender.send_msg(peer[:ip], peer[:port], "Coordinator")
          log("debug", "my ID is #{my_id} and I'm Coordinator")
        end
      end
    end

  end

  def election

  end

  def ok

  end

end