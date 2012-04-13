class SimpleLogger

  @priority # logging treshold

  def initialize(p)
    #raise ArgumentError unless in array("debug", "info", "warning", "error"))
    # TODO constants SimpleLogger.debug ...
    # TODO parameter "where" stdout/stder/file

    @priority = p
  end

  def log(priority, who, msg)
    # if priority < logging treshold -> don't log
    # TODO puts on STDERR
    # TODO smart indent
    STDERR.puts("[#{Time.now.to_s}] [#{priority.upcase!}] [#{who}] - #{msg}\n")
  end

end