module Loggable

  def log(priority, msg)
    @logger.log(priority, self.class.name, msg)
  end

end