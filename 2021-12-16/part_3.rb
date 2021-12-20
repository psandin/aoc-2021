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
  def initialize(remainder, mode: 'bin')
    @version = 0
    @type = 4
    @value = 0
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
      puts "!!! bad backet type: #{@type}"
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
    pretty_str += "#{istr}version => #{@version}\n"
    pretty_str += "#{istr}type => #{@type}\n"
    if @value.nil?
      pretty_str +=  "#{istr}length_in_bits => #{@length_in_bits}\n"
      pretty_str +=  "#{istr}length => #{@length}\n"
      pretty_str +=  "#{istr}children [\n"
      @children.each do |p|
        child_indent = indent + 1
        cistr = ''.rjust(child_indent * 2, ' ')
        pretty_str += "#{cistr}{\n"
        pretty_str += p.pretty(child_indent + 1)
        pretty_str += "#{cistr}}\n"
      end
      pretty_str +=  "#{istr}]\n"
    else
      pretty_str +=  "#{istr}value => #{@value}\n"
    end
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
      puts "Bad encoding mode [#{mode}]"
    end
  end
end

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
