require 'pp'
require 'optparse'

$args = {
  file: File.dirname(__FILE__) + "/input"
}
OptionParser.new do |opts|
  opts.on('-s', '--simple') do
    $args[:file] = File.dirname(__FILE__) + "/input.simple"
  end
  opts.on('-f PATH', '--file PATH', String) do |path|
    $args[:file] = path
  end
  opts.on('-v', '--verbose') do
    $args[:verbose] = true
  end
end.parse!

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/)
end

def parse_input(lines)
  points = []
  while (l = lines.shift) != ''
    points.push(
      l.split(/,/).map {|i| i.to_i}
    )
  end
  operations = lines.map do |l|
    _, _, l = l.split(/ /)
    l = l.split(/=/)
    {axis: l[0], value:l[1].to_i}
  end
  return points, operations
end

def transform(points, operation)
  i = operation[:axis] == 'x' ? 0 : 1
  points.map do |p|
    next if p[i] < operation[:value]
    p[i] = (p[i] - (2*operation[:value])).abs
  end
  points = points.uniq
end

def render(points)
  max = [0,1].map do |j|
    points.reduce do  |o, i|
      o = o[j] if o.kind_of?(Array)
      [o, i[j]].max
    end
  end
  (0..max[1]).each do |y|
    (0..max[0]).each do |x|
      print points.include?([x, y]) ? '#' : ' '
    end
      puts
  end
end

points, operations = parse_input(slurp($args[:file]))

operations.each { |o| transform(points,o) }
render(points.uniq)

# dest =  abs(src - (2*fold_point)), ie 13 fold 7 is 1 = abs(13 - (2*7)), 10f7 = 4 = abs(10 - (2*7))