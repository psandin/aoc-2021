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

class NoInputException < StandardError
end

class BadInstructionException < StandardError
end

# Adding number? to string
class String
  def number?
    to_i.to_s == self
  end
end

def execute_instructions(inputs, instructions)
  registers = {
    'w' => 0,
    'x' => 0,
    'y' => 0,
    'z' => 0
  }
  puts inputs.to_s
  instructions.each_with_index do |l, i|
    print "#{(i + 1).to_s.rjust(3, '0')}: #{l}\t" if $args[:verbose]
    (op, a, b) = l.split(/ /)
    op = '#' if op.nil?
    v = !b.nil? && b.number? ? b.to_i : registers[b]
    case op
    when '#'
      print "\t" if $args[:verbose]
    # inp a - Read an input value and write it to variable a.
    when 'inp'
      v = inputs.shift
      raise NoInputException if v.nil?

      registers[a] = v.to_i
    # add a b - Add the value of a to the value of b, then store the result in variable a.
    when 'add'
      registers[a] += v
    # mul a b - Multiply the value of a by the value of b, then store the result in variable a.
    when 'mul'
      registers[a] *= v
    # div a b - Divide the value of a by the value of b, truncate the result to an integer,
    # then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
    when 'div'
      registers[a] = (registers[a].to_f / v).truncate
    # mod a b - Divide the value of a by the value of b, then store the remainder in variable a.
    # (This is also called the modulo operation.)
    when 'mod'
      registers[a] = registers[a] % v
    # eql a b - If the value of a and b are equal, then store the value 1 in variable a.
    # Otherwise, store the value 0 in variable a.
    when 'eql'
      registers[a] = registers[a] == v ? 1 : 0
    else
      raise BadInstructionException, "!!! bad instruction: [#{op}]"
    end
    next unless $args[:verbose]

    print registers.to_s
    packed = registers['z']
    stack = []
    while packed.positive?
      stack.push(packed % 26)
      packed /= 26
    end
    puts stack.to_s
  end
  puts 'good' if $args[:verbose] && (registers['z']).zero?
  puts registers
end

instructions = slurp($args[:file])

# Part 1

# ABFGGFDEEDCCBA
# G w[4] = w[3] + (6 - 6)
# F w[5] = w[2] + (12 - 14)
# E w[8] = w[7] + (12 - 8)
# D w[9] = w[6] + (7 - 15)
# C w[11] = w[10] + (6 - 11)
# B w[12] = w[1] + (9 - 13)
# A w[13] = w[0] + (1 - 4)
# 99999795919456

inputs = '99999795919456'.chars.map(&:to_i)
execute_instructions(inputs, instructions).to_s

# Part 2

# ABFGGFDEEDCCBA
# G w[4] = w[3]
# F w[5] = w[2] - 2
# E w[8] = w[7] + 4
# D w[9] = w[6] - 8
# C w[11] = w[10] - 5
# B w[12] = w[1] - 4
# A w[13] = w[0] - 3
# 45311191516111

inputs = '45311191516111'.chars.map(&:to_i)
execute_instructions(inputs, instructions).to_s
