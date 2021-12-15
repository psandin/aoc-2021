# frozen_string_literal: true

require 'pp'
require 'optparse'
require 'set'

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

def find_low_points(height_map)
  @max_y = height_map.length - 1
  @max_x = height_map[0].length - 1
  mins = []
  height_map.each_with_index do |r, y|
    r.each_with_index do |e, x|
      mins.push([x, y]) if
      (x.zero?       || (height_map[y][x - 1] > e)) &&
      ((x == @max_x) || (height_map[y][x + 1] > e)) &&
      (y.zero?       || (height_map[y - 1][x] > e)) &&
      ((y == @max_y) || (height_map[y + 1][x] > e))
    end
  end
  mins
end

def expand_basin(height_map, origin)
  basin_set = Set[origin]
  basin_size = -1
  while basin_size != basin_set.length
    basin_size = basin_set.length
    basin_set.each do |p|
      x, y = p
      basin_set += [[x - 1, y]] if x.positive? && (height_map[y][x - 1] < 9)
      basin_set += [[x + 1, y]] if (x < @max_x) && (height_map[y][x + 1] < 9)
      basin_set += [[x, y - 1]] if y.positive? && (height_map[y - 1][x] < 9)
      basin_set += [[x, y + 1]] if (y < @max_y) && (height_map[y + 1][x] < 9)
    end
  end
  basin_set.to_a
end

# let's go
height_map = slurp($args[:file]).map { |l| l.chars.map(&:to_i) }
puts find_low_points(height_map).map { |l| expand_basin(height_map, l) }
                                .map(&:length).sort.slice(-3, 3).reduce(1, :*)
