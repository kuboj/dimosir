# TODO: ako zdtetekujem, ze som zomrel/ozivol ?

class DimosirKernel

  include Loggable

  @peer_self
  @peer_master

  @logger
  @db
  @sender

  def initialize(l, d, s, p)
    @logger = l
    @db = d
    @sender = s
    @peer_self = p
    #@peer_master = ?
  end

  def start
    start_election
  end

  def get_peer_self
    return @peer_self
  end

  def consume_message(peer_from, msg)
    Thread.new do
      log(SimpleLogger::DEBUG, "Got msg from #{peer_from.info}): #{msg}")
      if msg == "s"
        start_election
      end

      if msg == Election::MSG_ELECTION
        log(SimpleLogger::DEBUG, "got msg election from #{peer_from.info}")
        if peer_from < @peer_self
          @sender.send_msg(peer_from, Election::MSG_ALIVE)
          Thread.new { start_election }
        end

        #if peer_from > @peer_self
        #  log(SimpleLogger::DEBUG, "just heard Election:MSG_ELECTION from higher peer (#{peer_from.info})")
        #  @heard_from_higher = true
        #end
      end

      if msg == Election::MSG_MASTER
        log(SimpleLogger::DEBUG, "ok, #{peer_from.info} is master.")
      end

      if msg == Election::MSG_ALIVE
        log(SimpleLogger::DEBUG, "#{peer_from.info} is alive, i cannot be master")
        @heard_from_higher = true
      end

    end
  end

  def start_election
    log(SimpleLogger::DEBUG, "start_election")
    @heard_from_higher = false
    peers = @db.get_peers(:id => {:$ne => @peer_self.id}) # all other peers but me

    peers.each do |peer|
      log(SimpleLogger::DEBUG, "sending Election::MSG_ELECTION to #{peer.info}")
      @sender.send_msg(peer, Election::MSG_ELECTION) if peer > @peer_self
    end

    log(SimpleLogger::DEBUG, "waiting for election")
    sleep(5)
    log(SimpleLogger::DEBUG, "end of waiting for election. heard_from_higher: #@heard_from_higher")

    if !@heard_from_higher
      log(SimpleLogger::DEBUG, "broadcasting that I AM THE MASTER")
      peers.each { |peer| @sender.send_msg(peer, Election::MSG_MASTER) }
    end

  end

end