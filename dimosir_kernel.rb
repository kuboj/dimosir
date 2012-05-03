class DimosirKernel

  include Loggable

  @peer_self
  @peer_master

  @logger
  @db
  @sender
  @election

  def initialize(l, d, s, p, e)
    @logger = l
    @db = d
    @sender = s
    @peer_self = p
    @election = e

    @election.on_new_master = Proc.new do |new_master|
      if @peer_self == new_master
        log(DEBUG, "I am still master, heh!")
      else
        log(DEBUG, "new master #{new_master.info}")
      end

      @peer_master = new_master
    end
  end

  def start
    @election.start_election
  end

  def consume_message(peer_from, msg)
    Thread.new do
      log(DEBUG, "Got msg from #{peer_from.info}): #{msg}")

=begin
msg_type = msg.split(".").first
msg_action = msg.split(".").last

if msg_type == "election"
  @election.send(msg_action, peer_from)
end
=end
      if msg == Election::MSG_ELECTION then @election.msg_election(peer_from) end
      if msg == Election::MSG_MASTER then @election.msg_master(peer_from) end
      if msg == Election::MSG_ALIVE then @election.msg_alive(peer_from) end


    end
  end

end