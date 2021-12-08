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
  digits_raw, numbers_raw = line.split(/\| /)
  numbers = numbers_raw.split(/ /)
  digits = digits_raw.split(/ /)
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
  right_candidates = identified[1].split(//)

  # Four
  identified[4] = symbols.select {|s| s.length == 4}[0]
  symbols.delete(identified[4])
  mid_candidates = identified[4].split(//) - right_candidates

  # Seven
  identified[7] = symbols.select {|s| s.length == 3}[0]
  symbols.delete(identified[7])
  top_symbol = (identified[7].split(//) - right_candidates)[0]

  # Six
  six_candidates = symbols.select {|s| s.length == 6}
  identified[6] = six_candidates.select{|s|
    (s.include?(right_candidates[0]) and not s.include?(right_candidates[1])) or
    (s.include?(right_candidates[1]) and not s.include?(right_candidates[0]))
  }[0]
  symbols.delete(identified[6])
  bottom_left_candidates = identified[6].split(//) - mid_candidates - right_candidates - [top_symbol]
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

  # Canonicalize
  identified.each_pair { |k, v| 
    identified[k] = identified[k].chars.sort.join
  }

  # Swap keys and values since that's the operation we really want
  identified.invert
end

def translate_number(symbols, values)
  r = values.map { |v| symbols[v.chars.sort.join].to_s}.join.to_i
end

raw_lines = slurp($args[:file])
values = raw_lines.map { |l| parse_line(l) }
int_values = values.map do |l|
  symbol_map = identify_symbols(l[0])
  puts "#{symbol_map}"
  translate_number(symbol_map, l[1])
end
solution = int_values.sum
puts "#{int_values}"
puts "solution: #{solution}"


