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

def parse_line(line)
  digits_raw, numbers_raw = line.split(/\| /)
  numbers = numbers_raw.split(/ /).map {|c| c.chars.sort.join}
  digits = digits_raw.split(/ /).map {|c| c.chars.sort}
  return [digits, numbers]
end

def identify_symbols(symbols)
  identified = {}

  # Eight
  identified[8] = symbols.select {|s| s.length == 7}[0]
  symbols.delete(identified[8])

  # One
  identified[1] = symbols.select {|s| s.length == 2}[0]
  symbols.delete(identified[1])
  right_candidates = identified[1]

  # Four
  identified[4] = symbols.select {|s| s.length == 4}[0]
  symbols.delete(identified[4])
  mid_candidates = identified[4] - right_candidates

  # Seven
  identified[7] = symbols.select {|s| s.length == 3}[0]
  symbols.delete(identified[7])
  top_symbol = (identified[7] - right_candidates)[0]

  # Six
  six_candidates = symbols.select {|s| s.length == 6}
  identified[6] = six_candidates.select{|s|
    (s.include?(right_candidates[0]) and not s.include?(right_candidates[1])) or
    (s.include?(right_candidates[1]) and not s.include?(right_candidates[0]))
  }[0]
  symbols.delete(identified[6])
  bottom_left_candidates = identified[6] - mid_candidates - right_candidates - [top_symbol]
  bottom_right = identified[6].include?(right_candidates[0]) ? right_candidates[0] : right_candidates[1]
  top_right = (right_candidates - [bottom_right])[0]

  # Nine
  nine_candidates = symbols.select {|s| s.length == 6}
  identified[9] = nine_candidates.select{|s|
    (s.include?(bottom_left_candidates[0]) and not s.include?(bottom_left_candidates[1])) or
    (s.include?(bottom_left_candidates[1]) and not s.include?(bottom_left_candidates[0]))
  }[0]
  symbols.delete(identified[9])
  bottom_symbol = identified[9].include?(bottom_left_candidates[0]) ? bottom_left_candidates[0] : bottom_left_candidates[1]

  # Zero
  identified[0] = symbols.select {|s| s.length == 6}[0]
  symbols.delete(identified[0])
  top_left = identified[0].include?(mid_candidates[0]) ? mid_candidates[0] : mid_candidates[1]
  bottom_left = (bottom_left_candidates - [bottom_symbol])[0]

  # Five
  identified[5] = symbols.select {|s| s.length == 5}.select{|s| not s.include?(top_right)}[0]
  symbols.delete(identified[5])

  # Two
  identified[2] = symbols.select {|s| s.length == 5}.select{|s| s.include?(bottom_left)}[0]
  symbols.delete(identified[2])

  # Three
  identified[3] = symbols[0]

  # Swap keys and values since that's the operation we really want
  identified.each_with_object({}) { |(k,v),o| o[v.join] = k}
end

def elegant_identify_symbols(symbols)
  identified = {}

  identified[8] = symbols.find {|s| s.length == 7}
  identified[1] = symbols.find {|s| s.length == 2}
  identified[4] = symbols.find {|s| s.length == 4}
  identified[7] = symbols.find {|s| s.length == 3}
  identified[3] = symbols.find {|s| s.length == 5 and (s - identified[7]).length == 2}
  identified[6] = symbols.find {|s| s.length == 6 and (s - identified[7]).length == 4}
  identified[2] = symbols.find {|s| s.length == 5 and (s - identified[4]).length == 3}
  identified[5] = symbols.find {|s| s.length == 5 and (s - identified[6]).length == 0}
  identified[0] = symbols.find {|s| s.length == 6 and (s - identified[5]).length == 2}
  identified[9] = symbols.find {|s| s.length == 6 and (s - identified[3]).length == 1}

  identified.each_with_object({}) { |(k,v),o| o[v.join] = k}
end

def translate_number(symbols, values)
  r = values.map { |v| symbols[v]}.join.to_i
end

raw_lines = slurp($args[:file])
values = raw_lines.map { |l| parse_line(l) }
int_values = values.map do |l|
  symbol_map = elegant_identify_symbols(l[0])
  puts "#{symbol_map}"
  translate_number(symbol_map, l[1])
end
solution = int_values.sum
puts "#{int_values}"
puts "solution: #{solution}"


