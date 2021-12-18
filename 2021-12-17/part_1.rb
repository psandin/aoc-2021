# frozen_string_literal: true

require 'optparse'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

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

  input_str.split(/\n/).first
end

def parse_target(line)
  _, cords = line.split(': x=')
  x_raw, y_raw = cords.split(', y=')
  x = x_raw.split('..').map(&:to_i).sort
  y = y_raw.split('..').map(&:to_i).sort
  { x: (x[0]..x[1]), y: (y[0]..y[1]) }
end

def xmatch(point, target)
  target[:x].include?(point[:x])
end

def ymatch(point, target)
  target[:y].include?(point[:y])
end

def in_target(point, target)
  xmatch(point, target) && ymatch(point, target)
end

def display_path(data)
  data[:points].each do |p|
    x = p[:x].to_s
    x = x.bold if p[:xmatch]
    y = p[:y].to_s
    y = y.bold if p[:ymatch]
    puts "x => #{x} y => #{y} hit => #{p[:hit]}"
  end
  puts "max y => #{data[:maxy]}"
  puts '================'
end

def calc_x_range(target)
  minx = Math.sqrt(((2 * target.min) + 0.25) - (1 / 2)).ceil - 2
  maxx = Math.sqrt(((2 * target.max) + 0.25) - (1 / 2)).floor + 2
  minx..maxx
end

def trace_shot(initx, inity, target)
  history = {}
  history[:points] = [{ x: 0, y: 0 }]
  history[:maxy] = 0
  loop do
    last = history[:points].reverse.first
    current = { x: last[:x] + initx, y: last[:y] + inity }
    current[:ymatch] = ymatch(current, target)
    current[:xmatch] = xmatch(current, target)
    current[:hit] = in_target(current, target)
    history[:hit] = true if current[:hit]
    history[:maxy] = current[:y] if current[:y] > history[:maxy]
    history[:points].push(current)
    inity -= 1
    initx += (initx.positive? ? -1 : 1) unless initx.zero?
    break if current[:y] < target[:y].min
    break if current[:x] > target[:x].max
  end
  history
end

line = slurp($args[:file])
target_range = parse_target(line)
puts target_range.to_s
xrange = calc_x_range(target_range[:x])
runs = []
xrange.each do |x|
  (0..200).each do |y|
    runs.push(trace_shot(x, y, target_range))
  end
end

runs.select { |r| r[:hit] }.sort_by { |r| -r[:maxy] }.first(2).each { |r| display_path(r) }
