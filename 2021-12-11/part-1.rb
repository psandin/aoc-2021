require 'pp'
require 'optparse'
require 'term/ansicolor'
include Term::ANSIColor

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

def draw_array(arr)
  s = Math.sqrt(arr.length)
  arr.each_with_index do |v, i|
    if v == 0
      print "0 ".bold
    else
      print "#{v} "
    end
    puts if i % s == s - 1
  end
end

def cycle(arr)
  flashed = (0..arr.length-1).map { false }
  (0..arr.length-1).each do |i|
    next if flashed[i]
    arr[i] += 1
    flash_cell(i, arr, flashed) if arr[i] == 10
  end
  flashed.map {|c| c ? 1 : 0}.sum
end

def flash_cell(i, arr, flashed)
  return if flashed[i]
  arr[i] = 0
  flashed[i] = true
  s = Math.sqrt(arr.length)

  neighbors = [s, -s]
  neighbors.push(1, s+1,-s+1) unless i % s == s -1
  neighbors.push(-1,s-1,-s-1) unless i % s == 0

  neighbors.each do |m|
    if i+m >= 0 and i+m < arr.length
      next if flashed[i+m]
      arr[i+m] += 1
      flash_cell(i+m, arr, flashed) if arr[i+m] == 10
    end
  end
end

linear_array = slurp($args[:file]).map { |l| l.chars.map { |c| c.to_i } }.reduce(:+)

draw_array(linear_array) if $args[:verbose]

flashes = (1..100).map {
  flashed = cycle(linear_array)
  draw_array(linear_array) if $args[:verbose]
  flashed
}
puts "#{flashes.sum}"