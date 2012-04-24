class InputReader

  include Loggable

  @logger
  @sender

  def initialize(l, s)
    @logger = l
    @sender = s
  end

  def start
    loop do
      port = STDIN.gets.chomp.to_i
      msg = STDIN.gets.chomp
      log(SimpleLogger::DEBUG, "Got on input: #{port}, #{msg}")
      @sender.send_msg(Peer.new(:ip => "127.0.0.1", :port => port), msg)
    end
  end

end