class InputReader

  include Loggable

  @logger
  @sender
  @peer_self

  def initialize(l, s, p)
    @logger = l
    @sender = s
    @peer_self = p
  end

  def start
    loop do
      port = STDIN.gets.chomp.to_i
      msg = STDIN.gets.chomp
      log("debug", "Got on input: #{port}, #{msg}")
      @sender.send_msg(@peer_self, Peer.new(:ip => "127.0.0.1", :port => port), msg)
    end
  end

end