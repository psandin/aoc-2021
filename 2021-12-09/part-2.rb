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

def find_low_points (height_map)
  @max_y = height_map.length - 1
  @max_x = height_map[0].length - 1
  mins = []
  height_map.each_with_index do |r,i|
    r.each_with_index do |e, j|
      taller = 0
      if j == 0
        taller += 1
      elsif height_map[i][j-1] > e
        taller += 1
      end

      if i == 0
        taller += 1
      elsif height_map[i-1][j] > e
        taller += 1
      end

      if j == @max_x
        taller += 1
      elsif height_map[i][j+1] > e
        taller += 1
      end

      if i == @max_y
        taller += 1
      elsif height_map[i+1][j] > e
        taller += 1
      end

      mins.push([j, i]) if taller == 4
    end
  end
  return mins
end

def expand_basin(height_map, origin)
  basin_elements = [origin]
  basin_size = - 1
  while basin_size != basin_elements.length
    basin_size = basin_elements.length
    basin_elements.each do |p|
      x, y = p
      if x > 0 and height_map[y][x - 1] < 9 and not basin_elements.include?([x - 1, y])
        basin_elements.push([x - 1, y])
      end
      if x < @max_x and height_map[y][x + 1] < 9 and not basin_elements.include?([x + 1, y])
        basin_elements.push([x + 1, y])
      end
      if y > 0 and height_map[y - 1][x] < 9 and not basin_elements.include?([x, y - 1])
        basin_elements.push([x, y - 1])
      end
      if y < @max_y and height_map[y + 1][x] < 9 and not basin_elements.include?([x, y + 1])
        basin_elements.push([x, y + 1])
      end
    end
  end
  return basin_elements
end

#let's go
height_map = slurp($args[:file]).map { |l| l.split(//).map { |i| i.to_i }}
puts find_low_points(height_map).map { |l| expand_basin(height_map, l) }
  .map { |b| b.length  }.sort.reverse.slice(0,3).reduce(1, :*)
