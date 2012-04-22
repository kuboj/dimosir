module Loggable

  def log(priority, msg)
    @logger.llog(priority, self.class.name, msg)
  end

end