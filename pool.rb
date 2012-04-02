require "thread"

class Task

  attr_accessor :last_run
  attr_reader :periodicity
  attr_reader :script_filename
  attr_reader :arguments

  def initialize(p, s, a)
    unless p.is_a? Integer
      raise ArgumentError, "Periodicity has to be integer"
    end
    unless File.exists?(s)
      raise ArgumentError, "Script file does not exist"
    end

    @periodicity = p
    @script_filename = s
    @arguments = a
    @last_run = -1
  end

  def run
    out = `bash #{@script_filename} #{@arguments}`
    puts out
  end

end


class JobExecutor

  PRODUCER_SLEEP_TIME = 1
  MAX_NUM_OF_THREADS = 10

  @tasks
  @queue
  @threads
  @run

  def initialize(tasks)
    @tasks = Array.new(tasks)
    @queue = Queue.new
    @threads = Array.new
    @run = true

    start_job_producing
    start_job_consuming
  end

  def start_job_producing
    Thread.new do
      while @run do
        @tasks.each do |t|
          if (Time.now.to_i - t.last_run) > t.periodicity
            @queue.push(Task.new(t.periodicity, t.script_filename, t.arguments))
            t.last_run = Time.now.to_i
          end
        end
        puts "#{@queue.size} items in queue. sleepz nao."
        sleep(PRODUCER_SLEEP_TIME)
      end
    end
  end

  def start_job_consuming
    MAX_NUM_OF_THREADS.times do |i|
      @threads << Thread.new do
        puts "Thread #{i} started!"
        while @run do
          #puts "Thread #{i}: can i haz task plz ?"
          task = @queue.pop
          #puts "i hadz task! let conzume it!"
          task.run # takes some time
        end
      end
    end
  end

  # TODO: add_task, remove_tasks, update_tasks, clear_jobs, CONST - max jobs ...
  # if there are too many undone jobs -> exception/warning/clear jobs queue

end
