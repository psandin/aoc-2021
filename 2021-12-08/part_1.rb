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

def parse_line(line)
  puts line.to_s
  digits_raw, numbers_raw = line.split(/\| /)
  puts digits_raw.to_s
  puts numbers_raw.to_s
  numbers = numbers_raw.split(/ /)
  digits = digits_raw.split(/ /)
  puts digits.to_s
  puts numbers.to_s
  puts
  [digits, numbers]
end

def count_simple_cases(line)
  _, numbers = line
  numbers.map do |i|
    if i.length == 2 ||
       i.length == 3 ||
       i.length == 4 ||
       i.length == 7
      1
    else
      0
    end
  end.sum
end

raw_lines = slurp($args[:file])
puts raw_lines.to_s
puts
values = raw_lines.map { |l| parse_line(l) }
puts values.to_s
counts = values.map { |l| count_simple_cases(l) }
puts counts.to_s
puts counts.sum.to_s
