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

def find_low_points(height_map)
  max_y = height_map.length - 1
  max_x = height_map[0].length - 1
  puts "max y #{max_y}"
  puts "max x #{max_x}"
  mins = []
  height_map.each_with_index do |r, i|
    r.each_with_index do |e, j|
      print "judging #{e} @ (#{j}, #{i}) "
      taller = 0
      taller += 1 if j.zero? || (!j.zero? && height_map[i][j - 1] > e)
      taller += 1 if i.zero? || (!i.zero? && height_map[i - 1][j] > e)
      taller += 1 if j == max_x || (j != max_x && height_map[i][j + 1] > e)
      taller += 1 if i == max_y || (i != max_y && height_map[i + 1][j] > e)
      puts "score: #{taller}"
      mins.push(e.to_i) if taller == 4
    end
  end
  mins
end

height_map = slurp($args[:file]).map(&:chars)
mins = find_low_points(height_map)
puts mins.to_s
solution = mins.sum + mins.length
puts "solution #{solution}"
