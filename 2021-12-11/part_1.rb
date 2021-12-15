# frozen_string_literal: true

require 'pp'
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

  input_str.split(/\n/)
end

def draw_array(arr)
  s = Math.sqrt(arr.length)
  arr.each_with_index do |v, i|
    print v.zero? ? '0 '.bold : "#{v} "
    puts if i % s == s - 1
  end
end

def cycle(arr)
  flashed = (0..arr.length - 1).map { false }
  (0..arr.length - 1).each do |i|
    next if flashed[i]

    arr[i] += 1
    flash_cell(i, arr, flashed) if arr[i] == 10
  end
  flashed.count(true)
end

def flash_cell(idx, arr, flashed)
  return if flashed[idx]

  arr[i] = 0
  flashed[i] = true
  s = Math.sqrt(arr.length)

  neighbors = [s, -s]
  neighbors.push(1, s + 1, -s + 1) unless idx % s == s - 1
  neighbors.push(-1, s - 1, -s - 1) unless (idx % s).zero?

  neighbors.each do |m|
    next unless (idx + m >= 0) && (idx + m < arr.length)
    next if flashed[idx + m]

    arr[idx + m] += 1
    flash_cell(idx + m, arr, flashed) if arr[idx + m] == 10
  end
end

linear_array = slurp($args[:file]).map { |l| l.chars.map(&:to_i) }.reduce(:+)

draw_array(linear_array) if $args[:verbose]

flashes = (1..100).map do
  flashed = cycle(linear_array)
  draw_array(linear_array) if $args[:verbose]
  flashed
end
puts flashes.sum.to_s
