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
  digits_raw, numbers_raw = line.split(/\| /)
  numbers = numbers_raw.split(/ /).map { |c| c.chars.sort.join }
  digits = digits_raw.split(/ /).map { |c| c.chars.sort }
  [digits, numbers]
end

def elegant_identify_symbols(symbols)
  identified = {}

  identified[8] = symbols.find { |s| s.length == 7 }
  identified[1] = symbols.find { |s| s.length == 2 }
  identified[4] = symbols.find { |s| s.length == 4 }
  identified[7] = symbols.find { |s| s.length == 3 }
  identified[3] = symbols.find { |s| s.length == 5 and (s - identified[7]).length == 2 }
  identified[6] = symbols.find { |s| s.length == 6 and (s - identified[7]).length == 4 }
  identified[2] = symbols.find { |s| s.length == 5 and (s - identified[4]).length == 3 }
  identified[5] = symbols.find { |s| s.length == 5 and (s - identified[6]).length.zero? }
  identified[0] = symbols.find { |s| s.length == 6 and (s - identified[5]).length == 2 }
  identified[9] = symbols.find { |s| s.length == 6 and (s - identified[3]).length == 1 }

  identified.each_with_object({}) { |(k, v), o| o[v.join] = k }
end

def translate_number(symbols, values)
  values.map { |v| symbols[v] }.join.to_i
end

raw_lines = slurp($args[:file])
values = raw_lines.map { |l| parse_line(l) }
int_values = values.map do |l|
  symbol_map = elegant_identify_symbols(l[0])
  puts symbol_map.to_s
  translate_number(symbol_map, l[1])
end
solution = int_values.sum
puts int_values.to_s
puts "solution: #{solution}"
