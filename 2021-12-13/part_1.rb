# frozen_string_literal: true

require 'pp'
require 'optparse'

$args = {
  file: "#{File.dirname(__FILE__)}/input"
}
OptionParser.new do |opts|
  opts.on('-s', '--simple') do
    $args[:file] = "#{File.dirname(__FILE__)}/input.simple"
  end
  opts.on('-f PATH', '--file PATH', String) do |path|
    $args[:file] = path
  end
  opts.on('-v', '--verbose') do
    $args[:verbose] = true
  end
end.parse!

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/\n/)
end

def parse_input(lines)
  points = []
  while (line = lines.shift) != ''
    points.push(
      line.split(/,/).map(&:to_i)
    )
  end
  puts lines.to_s
  puts points.to_s
  operations = lines.map do |l|
    _, _, l = l.split(/ /)
    l = l.split(/=/)
    { axis: l[0], value: l[1].to_i }
  end
  puts operations.to_s
  [points, operations]
end

def transform(points, operation)
  i = operation[:axis] == 'x' ? 0 : 1
  points.map do |p|
    next if p[i] < operation[:value]

    dest = (p[i] - (2 * operation[:value])).abs
    puts "Moving #{p[i]} to #{dest} across #{operation}"
    p[i] = dest
  end
  puts points.sort.to_s
  puts points.sort.uniq.to_s
  points.uniq
end

def render(points)
  (0..14).each do |y|
    (0..10).each do |x|
      print points.include?([x, y]) ? '#' : '.'
    end
    puts
  end
  puts
end

points, operations = parse_input(slurp($args[:file]))
puts points.length.to_s

points = transform(points, operations[0])
puts points.length.to_s

# part 2? kinda
# operations.each do |o|
#   points = transform(points,o)
#   puts "#{points.length}"
# end
# dest =  abs(src - (2*fold_point)), ie 13 fold 7 is 1 = abs(13 - (2*7)), 10f7 = 4 = abs(10 - (2*7))
