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

def parse_inputs(lines)
  lines.map { |l| l.split(/: /).reverse.first.to_i }
end

def play_game(pos)
  $rc = 0
  scores = [0, 0]
  while scores.all? { |e| e < 1000 }
    0.upto(1) do |p|
      rolls = [roll, roll, roll]
      pos[p] += rolls.sum
      pos[p] = pos[p].digits.first if pos[p] > 9
      pos[p] = 10 if pos[p].zero?
      scores[p] += pos[p]
      if $args[:verbose]
        puts "Player #{p + 1} rolls #{rolls} and moves to space #{pos[p]} for a total score of #{scores[p]}"
      end
      break if scores[p] >= 1000
    end
  end
  puts scores.to_s
  puts $rc
  prod = scores.min * $rc
  puts prod
end

def roll
  res = ($rc % 100) + 1
  $rc += 1
  res
end

raw_lines = slurp($args[:file])
starting_pos = parse_inputs(raw_lines)
play_game(starting_pos)
