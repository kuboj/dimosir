=begin
class Main

  def initialize
    _require("server")
  end

  def _require(filename)
    require("#{File.expand_path(File.dirname(__FILE__))}/#{filename}")
  end

  def start
    Server.run!
  end

end

m = Main.new
m.start

=end

$DEBUG = true

gem "sinatra"
gem "thin"

require("#{File.expand_path(File.dirname(__FILE__))}/server")
require("#{File.expand_path(File.dirname(__FILE__))}/pool")

st = Thread.new do
  puts "Server running ..."
  Server.run!
end

pt = Thread.new do
  puts "Starting pool ..."
  tasks = Array.new
  10.times do |i|
    tasks.push(Task.new(i, "/home/bubo/RubymineProjects/bac1/scripts/kvik.sh", i))
  end

  js = JobExecutor.new(tasks)
end


st.join
pt.join

puts "Exit."