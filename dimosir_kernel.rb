class DimosirKernel

  @peer_id

  @logger
  @db
  @sender

  @ip
  @port

  @new_election
  @ok_received

  def initialize(l, d, s, i, p)
    @logger = l
    @db = d
    @sender = s
    @new_election = false
    @ip = i
    @port = p

    # TODO: check ip and port on input, IPAddr object
    # port has to be integer, > 1000, < 65000

    set_peer_id
  end

  def set_peer_id
    is_in_db = false
    peers = @db.get_peers(:ip => @ip, :port => @port, :order => :created_at.asc)
    if peers.count == 0
      log("debug", "peer id not in db, adding.")
      @peer_id = @db.add_peer(@ip, @port)
      log("debug", "peer id: #{@peer_id}")
    elsif peers.count == 1
      @peer_id = peers[0].id
      log("debug", "peer found in db. id: #{@peer_id}")
    else # peers.count > 1
      log("warning", "multiple peers with ip #{ip} and port #{port} found. taking first")
      @peer_id = peers[0].id
    end
  end

  def consume_message(msg)
    Thread.new do
      # TODO might not be valid message (?)
      log("debug", "got message! #{msg}")

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