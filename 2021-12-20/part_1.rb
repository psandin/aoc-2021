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

def compute_gol_rules
  (0..511).map do |v|
    live_cell = !(v & 16).zero?
    neighbor_count = (v & 495).to_s(2).count('1')
    (live_cell && (2..3).include?(neighbor_count)) || (!live_cell && neighbor_count == 3)
  end
end

def parse_input(lines)
  rules = lines.shift.chars.map { |c| c == '#' }
  lines.shift
  map = []
  lines.each_with_index do |r, y|
    r.chars.each_with_index do |c, x|
      map.push([x, y]) if c == '#'
    end
  end
  [map, rules]
end

def display_rules(rules)
  puts rules.map { |b| b ? '#' : '.' }.join
end

def tick(map, rules)
  new_map = []
  bounds = get_bounds(map)
  (bounds[:y][0]..bounds[:y][1]).each do |y|
    (bounds[:x][0]..bounds[:x][1]).each do |x|
      new_map.push([x, y]) if rules[index_for_cell(map, [x, y])]
    end
  end
  new_map
end

def get_bounds(map)
  xs = map.map { |e| e[0] }
  ys = map.map { |e| e[1] }
  { x: [xs.min - 1, xs.max + 1], y: [ys.min - 1, ys.max + 1] }
end

def display_map(map)
  bounds = get_bounds(map)
  (bounds[:y][0]..bounds[:y][1]).each do |y|
    (bounds[:x][0]..bounds[:x][1]).each do |x|
      print map.include?([x, y]) ? '#' : '.'
    end
    puts
  end
end

def index_for_cell(map, point)
  bstr = ''
  (-1..1).each do |ym|
    (-1..1).each do |xm|
      bstr += map.include?([point[0] + xm, point[1] + ym]) ? '1' : '0'
    end
  end
  bstr.to_i(2)
end

map, rules = parse_input(slurp($args[:file]))
display_map(map)
2.times do
  puts
  map = tick(map, rules)
  display_map(map)
end
puts map.length
