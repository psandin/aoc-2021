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

def parse_line(line)
  wat = line.split(/ -> /).map do |l|
    pair = l.split(/,/)
    {x: pair[0].to_i, y:pair[1].to_i}
  end
end

$vents = {}
def mark_line(line)
  if line[0][:x] == line[1][:x]
    smaller, larger = [line[0][:y], line[1][:y]].minmax
    puts "found verticle line #{line}" if $args[:verbose]
    (smaller..larger).each do |e|
      point = [line[0][:x],e]
      puts "Marking point #{point}" if $args[:verbose]
      $vents[point] = 0 if $vents[point].nil?
      $vents[point] += 1
    end
    return true
  end
  if line[0][:y] == line[1][:y]
    smaller, larger = [line[0][:x], line[1][:x]].minmax
    puts "found horizontal line #{line}" if $args[:verbose]
    (smaller..larger).each do |e|
      point = [e,line[0][:y]]
      puts "Marking point #{point}" if $args[:verbose]
      $vents[point] = 0 if $vents[point].nil?
      $vents[point] += 1
    end
    return true
  end

  y_delta = 1
  if line[0][:x] < line[1][:x]
    smaller, larger = [line[0][:x], line[1][:x]]
    y_delta = -1 if line[0][:y] > line[1][:y]
    y = line[0][:y]
  else
    smaller, larger = [line[1][:x], line[0][:x]]
    y_delta = -1 if line[1][:y] > line[0][:y]
    y = line[1][:y]
  end
  puts "Diagonal line #{line}" if $args[:verbose]

  (smaller..larger).each do |e|
      point = [e,y]
      puts "Marking point #{point}" if $args[:verbose]
      $vents[point] = 0 if $vents[point].nil?
      $vents[point] += 1
      y += y_delta
    end
    return true
end

def render_vents
  puts
  (0..9).each do |y|
    (0..9).each do |x|
      print $vents.key?([x,y]) ? $vents[[x,y]] : '.'
    end
    puts
  end
  puts
end

def count_vents
  count = 0
  $vents.each_value do |v|
    count += 1 if v > 1
  end
  return count
end

lines = slurp($args[:file]).map {|l| parse_line(l)}
puts "#{lines}" if $args[:verbose]
puts if $args[:verbose]
lines.each do |l|
  if mark_line(l)
     render_vents if $args[:verbose]
  end
end

puts "Double vents: #{count_vents}"
