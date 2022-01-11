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

$range_min = -50
$ramge_max = 50

def parse_steps(lines)
  instructions = []
  lines.each do |l|
    opv, ranges = l.split(/ /)
    parsed_ranges = ranges.split(/,/).map do |r|
      axis, raw_values = r.split(/=/)
      values = raw_values.split(/\.\./).map(&:to_i)
      [axis.to_sym, values]
    end
    next if parsed_ranges[0][1].min > $ramge_max
    next if parsed_ranges[0][1].max < $range_min
    next if parsed_ranges[1][1].min > $ramge_max
    next if parsed_ranges[1][1].max < $range_min
    next if parsed_ranges[2][1].min > $ramge_max
    next if parsed_ranges[2][1].max < $range_min
    parsed_ranges.push([:op, (opv == 'on')])
    instructions.push(Hash[parsed_ranges])
  end
  instructions
end

def execute_instructions(instructions)
  state = {}
  instructions.each do |e|
    (e[:x][0]..e[:x][1]).each do |x|
      (e[:y][0]..e[:y][1]).each do |y|
        (e[:z][0]..e[:z][1]).each do |z|
          state[[x,y,z]] = e[:op]
        end
      end
    end
  end
  state
end

def count_bits(state)
  state.map { |k,v| v }.select { |e| e  }.count
end

raw_lines = slurp($args[:file])
# puts raw_lines.to_s
instructions = parse_steps(raw_lines)
puts instructions
state = execute_instructions(instructions)
puts state.map { |k,v| v }.select { |e| e  }.count
