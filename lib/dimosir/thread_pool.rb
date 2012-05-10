require "thread"

module Dimosir

  class ThreadPool

    include Loggable

    @pool
    @size
    @jobs

    def initialize(l, size)
      set_logger(l)

      @size = size
      @jobs = Queue.new

      @pool = Array.new(@size) do |i|
        Thread.new do
          Thread.current[:id] = i

          catch(:exit) do
            loop do
              job, args = @jobs.pop
              job.call(*args)
            end
          end
        end
      end
    end

    def schedule(*args, proc)
      @jobs << [proc, args]
    end

    def shutdown
      @size.times do
        schedule Proc.new { throw :exit }
      end

      @pool.map(&:join)
    end

  end

end