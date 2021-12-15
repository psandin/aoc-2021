# frozen_string_literal: true

require 'pp'
require 'optparse'

args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
end.parse!(into: args)
raise OptionParser::MissingArgument, '--file' if args[:file].nil?

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/\n/)
end

$x_pos = 0
$y_pos = 0

def process_move(move_str)
  direction, magnitude = move_str.split
  $x_pos += magnitude.to_i if direction == 'forward'
  $y_pos += magnitude.to_i if direction == 'down'
  $y_pos -= magnitude.to_i if direction == 'up'
end

slurp(args[:file]).each do |l|
  process_move(l)
end

printf "End point (%<x>d, %<y>d)\n", x: $x_pos, y: $y_pos
printf "End product: %<prod>d\n", prod: $x_pos * $y_pos
