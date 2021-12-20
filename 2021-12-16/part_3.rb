# frozen_string_literal: false

require 'pp'
require 'optparse'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

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

# Class for parsing aoc-2012-12-16 data
class Packet
  class PacketTypeException < StandardError
  end

  class PacketModeException < StandardError
  end

  attr_reader :children, :type, :value, :length_in_bits
  attr_accessor :version

  def initialize(remainder = nil, version: 0, value: 0, mode: 'bin')
    @version = version
    @type = 4
    @value = value
    @length_in_bits = nil
    @length = nil
    @children = nil
    parse!(remainder, mode: mode) unless remainder.nil?
  end

  def parse!(remainder, mode: 'bin')
    remainder = remainder.hex.to_s(2).rjust(remainder.size * 4, '0') if mode == 'hex'
    _parse_headers!(remainder)
    if @type == 4
      _parse_literal!(remainder)
    else
      _parse_child_packets!(remainder)
    end
    remainder
  end

  def _parse_headers!(remainder)
    @version = remainder.slice!(0..2).to_i(2)
    @type = remainder.slice!(0..2).to_i(2)
    remainder
  end

  def _parse_literal!(remainder)
    last_digit = false
    pbstr = ''
    until last_digit
      bdigit = remainder.slice!(0..4)
      last_digit = bdigit.slice!(0).to_i.zero?
      pbstr += bdigit
    end
    @value = pbstr.to_i(2)
    remainder
  end

  def _parse_child_packets!(remainder)
    @value =  nil
    @children = []

    @length_in_bits = remainder.slice!(0).to_i.zero?
    if @length_in_bits
      @length = remainder.slice!(0..14).to_i(2)
      sub_bits = remainder.slice!(0..(@length - 1))
      @children.push(Packet.new(sub_bits)) until sub_bits.length < 11
    else
      @length = remainder.slice!(0..10).to_i(2)
      children_remaining = @length
      until (remainder.length < 11) || (children_remaining < 1)
        @children.push(Packet.new(remainder))
        children_remaining -= 1
      end
    end
    remainder
  end

  def evaluate
    case @type
    when 0 # sum
      @children.map(&:evaluate).sum
    when 1 # product
      @children.map(&:evaluate).reduce(:*)
    when 2 # min
      @children.map(&:evaluate).min
    when 3 # max
      @children.map(&:evaluate).max
    when 4 # value
      @value
    when 5 # gt
      @children[0].evaluate > @children[1].evaluate ? 1 : 0
    when 6 # lt
      @children[0].evaluate < @children[1].evaluate ? 1 : 0
    when 7 # eq
      @children[0].evaluate == @children[1].evaluate ? 1 : 0
    else
      raise PacketModeException, "!!! bad backet type: #{@type}"
    end
  end

  def sum_versions
    sum = @version
    return sum if @children.nil?

    @children.map(&:sum_versions).sum + sum
  end

  def pretty(indent = 0)
    istr = ''.rjust(indent * 2, ' ')
    pretty_str = ''
    pretty_str += "#{istr}version => (#{@version.to_s(2).rjust(3, '0')}) #{@version}\n"
    pretty_str += "#{istr}type => (#{@type.to_s(2).rjust(3, '0')}) #{@type}\n"
    if @value.nil?
      pretty_str += "#{istr}length_in_bits => (#{@length_in_bits ? '0' : '1'}) #{@length_in_bits}\n"
      blen = @length_in_bits ? @length.to_s(2).rjust(15, '0') : @length.to_s(2).rjust(11, '0')
      pretty_str += "#{istr}length => (#{blen}) #{@length}\n"
      child_str = ''
      child_bin = ''
      @children.each do |p|
        child_indent = indent + 1
        child_str += p.pretty(child_indent + 1)
        child_bin += p.encode
        child_str += "\n"
      end
      pretty_str += "#{istr}children (#{child_bin})\n"
      pretty_str += child_str
    else
      pretty_str += "#{istr}value => (#{_encode_literal}) #{@value}\n"
    end
    pretty_str
  end

  def _encode_literal
    vbits = @value.to_s(2)
    unless (vbits.length % 4).zero?
      pad_up_to = vbits.length + (4 - (vbits.length % 4))
      vbits = vbits.rjust(pad_up_to, '0')
    end
    byte_marker = '0'
    bstr = ''
    until vbits.length.zero?
      block = vbits.slice!(-4..-1)
      bstr = byte_marker + block + bstr
      byte_marker = '1'
    end
    bstr
  end

  def encode(mode = 'bin')
    bstr = ''
    bstr += @version.to_s(2).rjust(3, '0')
    bstr += @type.to_s(2).rjust(3, '0')
    if @type == 4
      bstr += _encode_literal
    elsif @length_in_bits
      bstr += '0'
      bstr += @length.to_s(2).rjust(15, '0')
      cblock = ''
      @children.each do |c|
        cblock += c.encode
      end
      bstr += cblock.ljust(@length, '0')
    else
      bstr += '1'
      bstr += @length.to_s(2).rjust(11, '0')
      @children.each do |c|
        bstr += c.encode
      end
    end
    case mode
    when 'bin'
      bstr
    when 'hex'
      pad_up_to = bstr.length + (4 - (bstr.length % 4))
      bstr = bstr.ljust(pad_up_to, '0')
      bstr.to_i(2).to_s(16).upcase
    else
      raise PacketModeException, "Bad encoding mode [#{mode}]"
    end
  end

  def type=(value)
    return if @type == value

    @type = value
    if value == 4
      self.value = 0
    else
      @value = nil
      @length = 0 if @length_in_bits.nil?
      @children = [] if @length_in_bits.nil?
      @length_in_bits = false if @length_in_bits.nil?
    end
  end

  def value=(value)
    @value = value
    @length_in_bits = nil
    @length = nil
    @children = nil
  end

  def length_in_bits=(value)
    raise PacketTypeException, 'Can not set length type for packets with type 4' if @type == 4

    @length_in_bits = value
    @length = @children.map { |c| @length_in_bits ? c.size : 1 }.sum
  end

  def add_child(child = nil, version: nil, value: nil)
    raise PacketTypeException, 'Can not add children to packets with type 4' if @type == 4

    child = Packet.new(version: version, value: value) if child.nil?
    @length += @length_in_bits ? child.size : 1
    @children.push(child)
  end

  def size
    encode.length
  end
end

np = Packet.new
np.version = 2
np.type = 4
np.value = 1337
puts np.pretty
puts np.encode('hex')
puts

packet2 = Packet.new(np.encode('hex'), mode: 'hex')
puts packet2.pretty
puts

p3 = Packet.new version: 2, value: 1337
puts p3.pretty
puts

parent = Packet.new
parent.version = 3
parent.type = 0
parent.length_in_bits = true
parent.add_child(version: 1, value: 13)
parent.add_child(version: 2, value: 37)
puts parent.pretty
puts parent.encode('hex')
puts
parent.length_in_bits = false
puts parent.pretty
puts parent.encode('hex')
puts

packets = {}
slurp($args[:file]).each do |hex_str|
  packets[hex_str] = Packet.new(hex_str.clone, mode: 'hex')
end

packets.each do |h, p|
  puts h
  puts "#{p.encode('hex')} [re-encoded]"
  puts p.pretty
  puts "Version sum: #{p.sum_versions}"
  puts "Result: #{p.evaluate}"
  puts
end
