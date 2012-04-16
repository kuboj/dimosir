class DimosirKernel

  @logger
  @db
  @sender

  @new_election
  @ok_received

  def initialize(l, d, s)
    @logger = l
    @db = d
    @sender = s
    @new_election = false
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