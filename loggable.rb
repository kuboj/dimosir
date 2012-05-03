module Loggable

  DEBUG   = 1
  INFO    = 2
  WARNING = 3
  ERROR   = 4

  def log(priority, msg)
    @logger.llog(priority, self.class.name, msg)
  end

end