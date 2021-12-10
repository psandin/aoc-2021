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

@expected = {}
@expected['('] = ')'
@expected['{'] = '}'
@expected['['] = ']'
@expected['<'] = '>'

puts "#{@expected}"

def validate(line)
  expected_closers = []
  bad_char = nil
  line.chars.each do |c|
    # puts "Pondering #{c}"
    if @expected.has_key?(c)
      expected_closers.push(@expected[c])
      # puts "Pushed: #{expected_closers}"
    elsif expected_closers.last == c
      expected_closers.pop
      # puts "Poped: #{expected_closers}"
    else
      puts "Expected #{expected_closers.last} found #{c}"
      bad_char = c
      break
    end
  end
  return bad_char
end

def score_errors(char)
  case char
  when ')'
    3
  when ']'
    57
  when '}'
    1197
  when '>'
    25137
  else
    0
  end
end
raw_lines = slurp($args[:file])
score = raw_lines.map { |l| validate(l) }.select { |i| not i.nil? }.map{ |c| score_errors(c)}.sum
puts "#{score}"
