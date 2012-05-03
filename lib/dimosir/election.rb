module Dimosir

  class Election

    include Loggable

    MSG_ELECTION  = "election.msg_election"
    MSG_MASTER    = "election.msg_master"
    MSG_ALIVE     = "election.msg_alive"

    WAIT_TIME = 3

    @logger
    @db
    @sender
    @peer_self
    @election_running

    attr_accessor :on_new_master  # called when msg_master received, param: new_master

    def initialize(l, d, s, p)
      @logger           = l
      @db               = d
      @sender           = s
      @peer_self        = p
      @election_running = Mutex.new
      @on_new_master    = nil
    end

    def start_election
      if @election_running.try_lock
        log(INFO, "Starting election")

        raise NoMethodError, "no :on_new_master Proc given" if @on_new_master.nil?

        @heard_from_higher = false # if there was no mutex this assign by second thread would cause election of second master

        higher_peers = @db.get_higher_peers(@peer_self)
        higher_peers.each do |peer|
          log(DEBUG, "sending Election::MSG_ELECTION to #{peer.info}")
          @sender.send_msg(peer, MSG_ELECTION)
        end

        log(DEBUG, "waiting for election")
        sleep(WAIT_TIME)
        log(DEBUG, "end of waiting for election. heard_from_higher?: #@heard_from_higher")

        i_am_master = !@heard_from_higher # here would first thread read "false" therefore i_am_master == true

        if i_am_master # if no higher peer sent me msg_alive then I am the master
          log(DEBUG, "broadcasting that I AM THE MASTER")
          all_peers = @db.get_all_peers # including myself therefore msg_master will be called by myself
          all_peers.each { |peer| @sender.send_msg(peer, MSG_MASTER) }
        end
      else
        log(DEBUG, "election already running")
      end
    end

    def msg_election(peer_from)
      log(INFO, "Got msg_election from #{peer_from.info}")

      if peer_from < @peer_self
        @sender.send_msg(peer_from, MSG_ALIVE)
        Thread.new { start_election }
      end
     end

    def msg_master(peer_from)
      log(SimpleLogger::INFO, "ok, #{peer_from.info} is master.")

      @on_new_master.call(peer_from)
    end

    def msg_alive(peer_from)
      log(SimpleLogger::INFO, "#{peer_from.info} is alive, i cannot be master")
      @heard_from_higher = true
    end

  end

end