require 'pp'
require 'optparse'

$args = {
  ticks: 80,
  delay: 2,
  birthage: 6,
}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, "--file" if $args[:file].nil?

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/,/)
end

positions = slurp($args[:file]).map {|i| i.to_i}

def cost_to_target(arr, target)
  costs = arr.map do |i| 
    c = (i - target).abs
    c*(c+1)/2 # see kids the trick is knowing to look up the iterative formulation in OEIS
  end
  return costs.sum
end

def brute_force(arr)
  min, max = arr.minmax
  costs = {}
  (min..max).each do |i|
    cost = cost_to_target(arr, i)
    costs[i] = cost
    puts "Brute force target: #{i} cost: #{cost}"
  end
  brute_target = costs.invert.sort[0]
  r = {target: brute_target[1], cost:brute_target[0]}
  puts "#{r}"
end

brute_force(positions)