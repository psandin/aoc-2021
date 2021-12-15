# frozen_string_literal: true

require 'pp'
require 'optparse'

$args = {
  ticks: 80,
  delay: 2,
  birthage: 6
}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, '--file' if $args[:file].nil?

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/,/)
end

positions = slurp($args[:file]).map(&:to_i)

def mean(arr)
  arr.sum.to_f / arr.length
end

def median(arr)
  counts = {}
  arr.each do |i|
    counts[i] = 0 if counts[i].nil?
    counts[i] += 1
  end
  counts.invert.sort.reverse[0][1]
end

def target(mean, median)
  target = mean.to_i
  return target if target == mean
  return target if mean > median

  target + 1
end

def cost_to_target(arr, target)
  costs = arr.map { |i| (i - target).abs }
  costs.sum
end

def brute_force(arr)
  min, max = arr.minmax
  costs = {}
  (min..max).each do |i|
    cost = cost_to_target(arr, i)
    costs[i] = cost
    puts "Brute force target: #{i} cost: #{cost}"
  end
  brute_target = costs.invert.min
  r = { target: brute_target[1], cost: brute_target[0] }
  puts r.to_s
end

data_mean   = mean(positions)
data_median = median(positions)
data_target = target(data_mean, data_median)
cost        = cost_to_target(positions, data_target)

puts "raw: #{positions}"
puts "mean: #{data_mean}"
puts "median: #{data_median}"
puts "target: #{data_target}"
puts "cost: #{cost}"
puts

brute_force(positions)
