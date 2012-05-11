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

      log(DEBUG, "Thread pool successfully initialized with size #@size")
    end

    def schedule(*args, job) # TODO: job has to be callable (responds to :call)
      log(DEBUG, "New proc scheduled. #{@jobs.size} jobs in queue")
      @jobs << [job, args]
    end

    def shutdown
      @size.times do
        schedule Proc.new { throw :exit }
      end

      @pool.map(&:join)
    end

  end

end