class InputReader

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
      log("debug", "Got on input: #{port}, #{msg}")
    end
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end