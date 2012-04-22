# TODO parameter "where" stdout/stder/file ?

class SimpleLogger

  include Loggable

  DEBUG   = 1
  WARNING = 2
  ERROR   = 3

  @constants # HashMap const_value => const_name
  @threshold # logging threshold

  def initialize(t)
    @constants = Hash.new
    self.class.constants.each do |c|
      @constants[self.class.const_get(c)] = c.id2name
    end

    raise ArgumentError, "#{t} is not valid logging threshold" unless @constants.include?(t)

    @threshold = t
    @logger = self
    log(DEBUG, "Logger initialized with logging threshold: #{@constants[t]}")
  end

  def llog(priority, who, msg)
    return if priority < @threshold

    # TODO smart indent in output
    STDERR.puts("[#{Time.now.to_s}] [#{@constants[priority]}] [#{who}] - #{msg}\n")
  end

  def self.get_log_levels_str
    str = "Logging level. Possible values: "
    self.constants.each do |c|
      str += "#{self.const_get(c)} - #{c.id2name.downcase}, "
    end

    return str
  end

  def self.get_log_level_values
    return self.constants.map { |c| self.const_get(c) }
  end

end