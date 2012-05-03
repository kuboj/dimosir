def kvik
	puts "kvik"
	yield(3)
end

kvik { |x| puts "parameter: #{x}"}
