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

@expected = {
  '(' => ')',
  '[' => ']',
  '{' => '}',
  '<' => '>'
}

@values = {
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4
}

def validate(line)
  expected_closers = []
  bad_line = false
  line.chars.each do |c|
    if @expected.key?(c)
      expected_closers.push(@expected[c])
    elsif expected_closers.last == c
      expected_closers.pop
    else
      bad_line = true
      break
    end
  end
  bad_line ? [] : expected_closers.reverse
end

def score_complete(charset)
  charset.reduce do |o, i|
    o = @values[o] if o.is_a? String
    (o * 5) + @values[i]
  end
end

valid_lines = slurp($args[:file]).map { |l| validate(l) }
scores = valid_lines.select { |a| a.length.positive? }.map { |l| score_complete(l) }.sort
puts scores[scores.length / 2]
