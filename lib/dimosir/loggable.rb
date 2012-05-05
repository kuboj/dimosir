module Dimosir

  module Loggable

    DEBUG   = 1
    INFO    = 2
    WARNING = 3
    ERROR   = 4

    def log(priority, msg)
      class_name = self.class.name.split("::").last
      @logger.llog(priority, class_name, msg)
    end

  end

end