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

@values = {}
@values[')']=1
@values[']']=2
@values['}']=3
@values['>']=4

def validate(line)
  expected_closers = []
  bad_line = false
  line.chars.each do |c|
    if @expected.has_key?(c)
      expected_closers.push(@expected[c])
    elsif expected_closers.last == c
      expected_closers.pop
    else
      bad_line = true
      break
    end
  end
  if not bad_line
    expected_closers.reverse
  else
    []
  end
end

def score_complete (charset)
  charset.reduce do |o, i|
    o = @values[o] if o.is_a? String
    (o * 5) + @values[i]
  end
end

scores = slurp($args[:file]).map { |l| validate(l) }.map { |l| score_complete(l) }.select { |i| not i.nil? }.sort
puts scores[scores.length / 2]

