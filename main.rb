# TODO all classes will extend "logable" -> "self.log" ?

$DEBUG = true
port = ARGV[0]

gem "ipaddress"

require("#{File.expand_path(File.dirname(__FILE__))}/listener")
require("#{File.expand_path(File.dirname(__FILE__))}/input_reader")
require("#{File.expand_path(File.dirname(__FILE__))}/simple_logger")
require("#{File.expand_path(File.dirname(__FILE__))}/sender")
require("#{File.expand_path(File.dirname(__FILE__))}/pool")

logger = SimpleLogger.new("debug")

# start listener
l = Listener.new(port, logger)
puts "Listener running on #{port}..."

lt = Thread.new do
  l.start
end

# start sender
s = Sender.new(logger)

# start input reader
i = InputReader.new
it = Thread.new do
  i.start
end

peers = [10000, 10001]
s = Sender.new
peers.each do |peer|
  next if peer.to_s == port.to_s
  msg = "hi, greetings from #{port}\0"
  puts "server at #{peer} says: #{s.send_msg("127.0.0.1", peer, msg)}"
end

# wait for threads
lt.join
it.join

=begin
pt = Thread.new do
  puts "Starting pool ..."
  tasks = Array.new
  10.times do |i|
    tasks.push(Task.new(i, "/home/bubo/RubymineProjects/bac1/scripts/kvik.sh", i))
  end

  js = JobExecutor.new(tasks)
end
=end

puts "Exit."