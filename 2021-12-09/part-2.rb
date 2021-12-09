require 'pp'
require 'optparse'
require 'set'

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

def find_low_points (height_map)
  @max_y = height_map.length - 1
  @max_x = height_map[0].length - 1
  mins = []
  height_map.each_with_index do |r,i|
    r.each_with_index do |e, j|
      mins.push([j, i]) if
      (j == 0      or height_map[i][j-1] > e) and
      (i == 0      or height_map[i-1][j] > e) and
      (j == @max_x or height_map[i][j+1] > e) and
      (i == @max_y or height_map[i+1][j] > e)
    end
  end
  return mins
end

def expand_basin(height_map, origin)
  basin_set = Set[origin]
  basin_size = - 1
  while basin_size != basin_set.length
    basin_size = basin_set.length
    basin_set.each do |p|
      x, y = p
      basin_set += [[x - 1, y]] if x > 0 and height_map[y][x - 1] < 9
      basin_set += [[x + 1, y]] if x < @max_x and height_map[y][x + 1] < 9
      basin_set += [[x, y - 1]] if y > 0 and height_map[y - 1][x] < 9
      basin_set += [[x, y + 1]] if y < @max_y and height_map[y + 1][x] < 9
    end
  end
  return basin_set.to_a
end

#let's go
height_map = slurp($args[:file]).map { |l| l.split(//).map { |i| i.to_i }}
puts find_low_points(height_map).map { |l| expand_basin(height_map, l) }
  .map { |b| b.length  }.sort.slice(-3,3).reduce(1, :*)
