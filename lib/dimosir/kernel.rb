# TODO: class role -> master, slave

module Dimosir

  class Kernel

    include Loggable

    @peer_self
    @peer_master

    @db
    @sender
    @election

    @master_thread
    @alive_peers
    @alive_peers_mutex

    @slave_thread
    @last_pinged

    # TODO: module "messages"
    MSG_PING = "kernel.ping"
    MSG_PONG = "kernel.pong"

    MSG_TASK_UPDATE = "task.update"
    MSG_TASK_RESCHEDULE = "task.reschedule"

    # TODO: put these in app_config
    MASTER_PING_INTERVAL = 10
    MASTER_PONG_WAIT_TIME = 1
    SLAVE_PING_INTERVAL = 20
    SLAVE_WAIT_TIME = 1

    def initialize(l, d, s, p, e, ts, jg, je, a)
      set_logger(l)

      @db             = d
      @sender         = s
      @peer_self      = p
      @election       = e
      @task_scheduler = ts
      @job_generator  = jg
      @job_executor   = je
      @alerter        = a

      @master_thread      = nil
      @alive_peers        = nil
      @alive_peers_mutex  = Mutex.new

      @slave_thread = nil
      @last_pinged  = 0

      # set handler for election results
      @election.on_new_master = Proc.new do |new_master|
        if @peer_self == new_master
          if @peer_master == new_master
            log(INFO, "I am still master, heh!")
          else
            log(INFO, "I am becoming master now!")
            become_master
          end
        else
          if @peer_master == @peer_self
            log(INFO, "I was master, now #{new_master.info} is master")
            become_slave
          else
            log(INFO, "New master is #{new_master.info}")
            become_slave if @slave_thread.nil?
          end
        end

        @peer_master = new_master
      end
    end

    def start
      Thread.new { @election.start_election } # result will determine role - slave/master
      Thread.new { @job_generator.start }
      Thread.new { @job_executor.start }
    end

    def consume_message(peer_from, msg)
      Thread.new do
        log(DEBUG, "Got msg from #{peer_from.info}): #{msg}")

        msg_type = msg.split(".").first
        msg_action = msg.split(".").last
        if msg_type == "election" then @election.send(msg_action, peer_from) end

        if msg == MSG_PING then handle_ping(peer_from) end
        if msg == MSG_PONG then handle_pong(peer_from) end

        if msg == MSG_TASK_UPDATE then @job_generator.reload_tasks end
        if msg == MSG_TASK_RESCHEDULE && @peer_self == @peer_master then reschedule_tasks end
      end
    end

    def become_master
      @master_thread = Thread.new do
        reschedule_tasks

        while @peer_master == @peer_self do
          @alive_peers = Hash.new
          peers_other = @db.get_other_peers(@peer_self)
          peers_other.each do |peer|
            @alive_peers[peer] = false
            @sender.send_msg(peer, MSG_PING)
          end

          sleep(MASTER_PONG_WAIT_TIME) # wait for MSG_PONG from pinged peers

          @alive_peers.each do |peer, alive|
            drop_peer(peer) unless alive
          end

          Thread.new { @alerter.check }

          sleep(MASTER_PING_INTERVAL)
        end
      end
    end

    def become_slave
      @last_pinged = Time.now.to_i

      @slave_thread = Thread.new do
        while @peer_master != @peer_self do
          pause = Time.now.to_i - @last_pinged
          if pause > SLAVE_PING_INTERVAL # if i wasn't pinged too long, master is probably dead
            log(INFO, "i wasn't pinged for #{pause} seconds, master is probably dead.")
            Thread.new { @election.start_election }
          end

          sleep(SLAVE_WAIT_TIME)
        end
      end
    end

    def handle_ping(peer_from)
      log(DEBUG, "pinged by #{peer_from.info}.")
      @last_pinged = Time.now.to_i
      @sender.send_msg(peer_from, MSG_PONG)
    end

    def handle_pong(peer_from)
      log(DEBUG, "got MSG_PONG from #{peer_from.info}")
      @alive_peers_mutex.synchronize do
        @alive_peers[peer_from] = true
      end
    end

    def drop_peer(peer)
      log(INFO, "Dropping #{peer.info}")

      tasks = peer.get_tasks
      tasks.each { |t| t.peer = nil; t.save }
      @db.del_peer(peer)
      reschedule_tasks
    end

    def require_reschedule
      @sender.send_msg(@peer_master, MSG_TASK_RESCHEDULE)
    end

    def reschedule_tasks
      #peers = @db.get_other_peers(@peer_master)
      peers = @db.get_all_peers
      tasks = @db.get_all_tasks
      @task_scheduler.reschedule(peers, tasks)
      peers.each { |p| @sender.send_msg(p, MSG_TASK_UPDATE) }
    end

  end

end