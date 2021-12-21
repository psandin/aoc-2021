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
  map = { lit: [], bounds: {}, border_state: false }
  lines.each_with_index do |r, y|
    r.chars.each_with_index do |c, x|
      map[:lit].push([x, y]) if c == '#'
    end
  end
  map[:bounds] = get_bounds(map[:lit])
  [map, rules]
end

def display_rules(rules)
  puts rules.map { |b| b ? '#' : '.' }.join
end

def tick(map, rules)
  new_lit = []
  (map[:bounds][:y][0] - 1..map[:bounds][:y][1] + 1).each do |y|
    (map[:bounds][:x][0] - 1..map[:bounds][:x][1] + 1).each do |x|
      new_lit.push([x, y]) if rules[index_for_cell(map, [x, y])]
    end
  end
  map[:lit] = new_lit
  map[:border_state] = (map[:border_state] && rules[511] == true) || (!map[:border_state] && rules[0] == true)
  if map[:border_state]
    map[:bounds][:y][0] -= 1
    map[:bounds][:x][0] -= 1
    map[:bounds][:y][1] += 1
    map[:bounds][:x][1] += 1
  else
    map[:bounds] = get_bounds(map[:lit])
  end
end

def get_bounds(map)
  xs = map.map { |e| e[0] }
  ys = map.map { |e| e[1] }
  { x: xs.minmax, y: ys.minmax }
end

def display_map(map)
  xbound = (map[:bounds][:x][0]..map[:bounds][:x][1])
  ybound = (map[:bounds][:y][0]..map[:bounds][:y][1])
  (map[:bounds][:y][0] - 1..map[:bounds][:y][1] + 1).each do |y|
    (map[:bounds][:x][0] - 1..map[:bounds][:x][1] + 1).each do |x|
      lit = xbound.include?(x) && ybound.include?(y) ? map[:lit].include?([x, y]) : map[:border_state]
      print lit ? '#' : '.'
    end
    puts
  end
  puts map[:lit].length
end

def index_for_cell(map, point)
  bstr = ''
  xbound = (map[:bounds][:x][0]..map[:bounds][:x][1])
  ybound = (map[:bounds][:y][0]..map[:bounds][:y][1])
  (-1..1).each do |ym|
    (-1..1).each do |xm|
      x = point[0] + xm
      y = point[1] + ym
      pred = xbound.include?(x) && ybound.include?(y) ? map[:lit].include?([x, y]) : map[:border_state]
      bstr += pred ? '1' : '0'
    end
  end
  bstr.to_i(2)
end

map, rules = parse_input(slurp($args[:file]))
display_map(map)
50.times do |i|
  puts
  tick(map, rules)
  display_map(map)
  puts "Round: #{i}"
end
