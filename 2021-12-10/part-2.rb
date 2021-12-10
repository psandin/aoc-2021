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

# puts "#{@expected}"

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
      # puts "Expected #{expected_closers.last} found #{c}"
      bad_char = c
      break
    end
  end
  if bad_char.nil?
    puts "#{score_complete(expected_closers)}"
    score_complete(expected_closers)
  else
    0
  end
end

def score_complete (charset)
  mul = charset.length + 1
  mul = 5
  charset = charset.reverse

  values = {}
  values[')']=1
  values[']']=2
  values['}']=3
  values['>']=4

  charset.reduce do |o, i|
    o = values[o] if o.is_a? String
    (o * 5) + values[i]
  end
end

raw_lines = slurp($args[:file])
scores = raw_lines.map { |l| validate(l) }.select { |i| i!=0 }.sort
puts "#{scores}"
puts scores[scores.length / 2]

