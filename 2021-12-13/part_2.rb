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
  # FYI to perl kids, 'line' is not lexically scoped to the while,
  # it's local to the method like everything else,
  # choose your names with caution
  while (line = lines.shift) != ''
    points.push(
      line.split(/,/).map(&:to_i)
    )
  end
  operations = lines.map do |l|
    _, _, l = l.split(/ /)
    l = l.split(/=/)
    { axis: l[0], value: l[1].to_i }
  end
  [points, operations]
end

def transform!(points, operation)
  i = operation[:axis] == 'x' ? 0 : 1
  points.map do |p|
    next if p[i] < operation[:value]

    p[i] = (p[i] - (2 * operation[:value])).abs
  end.uniq
end

def render(points)
  max = [0, 1].map do |j|
    points.reduce do |o, i|
      o = o[j] if o.is_a?(Array)
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

operations.each { |o| transform!(points, o) }
render(points.uniq)

# dest =  abs(src - (2*fold_point)), ie 13 fold 7 is 1 = abs(13 - (2*7)), 10f7 = 4 = abs(10 - (2*7))
