module Dimosir

  class SimpleLogger

    include Loggable

    @constants        # HashMap const_value => const_name
    @threshold        # logging threshold
    @modules_ignored

    def initialize(t, mi, f)
      @constants = Hash.new
      self.class.constants.each do |c|
        @constants[self.class.const_get(c)] = c.id2name
      end

      raise ArgumentError, "#{t} is not valid logging threshold" unless @constants.include?(t)

      @threshold = t
      @modules_ignored = mi.map { |m| m.downcase }
      @logger = self
      if f != ""
        @log_target = File.open(f, "a+")
      else
        @log_target = STDERR
      end
      log(DEBUG, "Logger initialized with logging threshold: #{@constants[t]}")
    end

    def llog(priority, who, msg)
      return if priority < @threshold || @modules_ignored.include?(who.downcase)

      # TODO smart indent in output
      @log_target.puts("[#{Time.now.to_s}] [#{@constants[priority]}] [#{who}] - #{msg}\n")
      @log_target.flush
    end

    def self.get_log_levels_str
      str = "Logging level. Possible values: "
      self.constants.each { |c| str += "#{self.const_get(c)} - #{c.id2name.downcase}, " }

      return str
    end

    def self.get_log_level_values
      return self.constants.map { |c| self.const_get(c) }
    end

  end

end