require 'pp'
require 'optparse'

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, "--file" if $args[:file].nil?

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/)
end

@working_set = []
def process_line(line)
  puts line if $args[:verbose]
  char_pos = 0 
  line.split(//).each do |c|
    @working_set[char_pos] = 0  if @working_set[char_pos].nil?
    @working_set[char_pos] += c.to_i
    char_pos += 1
  end
end

line_count = 0
slurp($args[:file]).each do |l|
  line_count += 1
  process_line(l)
end

max_set = []
min_set = []
@working_set.each do |b, i|
  if b/line_count.to_f > 0.5
    max_set.push "1"
    min_set.push "0"
  else
    max_set.push "0"
    min_set.push "1"
  end
end

gamma = max_set.join('').to_i(2)
epsilon = min_set.join('').to_i(2)
puts "gamma: #{gamma}" if $args[:verbose]
puts "epsilon: #{epsilon}" if $args[:verbose]
puts "Final: #{gamma * epsilon}"