class MessageRouter

  @loggee

  def initialize(l)
    @logger = l
  end

  def route(msg)
    # TODO might not be valid message (?``)
    # TODO
    log("debug", "got message! #{msg}")
  end

  # TODO: move this to superclass
  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end