require 'pp'
require 'optparse'

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, "--file" if $args[:file].nil?

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/)
end

def parse_line(line)
  puts "#{line}"
  digits_raw, numbers_raw = line.split(/\| /)
  puts "#{digits_raw}"
  puts "#{numbers_raw}"
  numbers = numbers_raw.split(/ /)
  digits = digits_raw.split(/ /)
  puts "#{digits}"
  puts "#{numbers}"
  puts
  return [digits, numbers]
end


def count_simple_cases(line)
  digits, numbers = line
  numbers.map { |i|
    (i.length == 2 ||
     i.length == 3 ||
     i.length == 4 ||
     i.length == 7) ? 1 :0
  }.sum
end

raw_lines = slurp($args[:file])
puts "#{raw_lines}"
puts
values = raw_lines.map { |l| parse_line(l) }
puts "#{values}"
counts = values.map { |l| count_simple_cases (l) }
puts "#{counts}"
puts "#{counts.sum}"