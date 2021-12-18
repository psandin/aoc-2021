# frozen_string_literal: true

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

$depth = -1
$depth_pad = ''

def dputs(str)
  puts "#{$depth_pad}#{str}" if $args[:verbose]
end

def show_slice (vbits, remainder)
  print "#{$depth_pad}#{vbits.to_s.bold}" if $args[:verbose]
  puts "#{remainder}" if $args[:verbose]
end

def to_bin (hex)
  hex.hex.to_s(2).rjust(hex.size*4, '0')
end

def parse_packet!(bpacket)
  $depth += 1
  $depth_pad = ''.rjust($depth*2, ' ')
  packet, remainder = parse_headers!(bpacket)
  if packet[:type] == 4
    packet[:value], remainder = parse_literal!(remainder)
  else
    packet, remainder = parse_sub_packets!(packet, remainder)
  end
  $depth -= 1
  $depth_pad = ''.rjust($depth*2, ' ')
  [packet, remainder]
end

def parse_headers!(bpacket)
  dputs "parse_headers! version"
  dputs bpacket
  vbits = bpacket.slice!(0..2)
  version = vbits.to_i(2)
  show_slice vbits, bpacket
  dputs "Version: #{version}"

  dputs "parse_headers! type"
  dputs bpacket
  tbits = bpacket.slice!(0..2)
  type = tbits.to_i(2)
  show_slice tbits, bpacket
  dputs "Type: #{type}"

  packet = {
    version: version,
    type: type
  }
  [packet, bpacket]
end

def parse_literal! (bstr)
  last_digit =  false
  pbstr = ''
  until last_digit
    dputs "parse_literal!"
    dputs bstr
    bdigit = bstr.slice!(0..4)
    show_slice bdigit, bstr
    last_digit = bdigit.slice!(0).to_i.zero?
    dputs "Is last? #{last_digit}"
    dputs "Digit: #{bdigit}"
    pbstr += bdigit
  end
  v = pbstr.to_i(2)
  [v, bstr]
end

def parse_sub_packets! (packet, remainder)
  packet[:children] = []
  dputs "parse_sub_packets! length_in_bits"
  dputs remainder
  blib = remainder.slice!(0)
  packet[:length_in_bits] = blib.to_i(2).zero?
  show_slice blib, remainder
  dputs "length_in_bits: #{packet[:length_in_bits]}"
  if packet[:length_in_bits]
    dputs "parse_sub_packets! length in bits"
    dputs remainder
    blen = remainder.slice!(0..14)
    packet[:length] = blen.to_i(2)
    show_slice blen, remainder
    dputs "length: #{packet[:length]}"
    dputs "parse_sub_packets! splitting child bits"
    dputs remainder
    sub_bits = remainder.slice!(0..(packet[:length]-1))
    show_slice sub_bits, remainder
    #min packet length is 11
    until (sub_bits.length < 11)
      child, sub_bits = parse_packet!(sub_bits)
      packet[:children].push(child)
    end
  else
    dputs "parse_sub_packets! length in packets"
    dputs remainder
    blen = remainder.slice!(0..10)
    packet[:length] = blen.to_i(2)
    show_slice blen, remainder
    dputs "length: #{packet[:length]}"
    children_remaining = packet[:length]
    until (remainder.length < 11) || (children_remaining < 1)
      child, remainder = parse_packet!(remainder)
      packet[:children].push(child)
      children_remaining -= 1
    end
  end
  [packet, remainder]
end

def pretty_packet(packet, indent = 0)
  istr = ''.rjust(indent*2, ' ')
  puts "#{istr}version => #{packet[:version]}"
  puts "#{istr}type => #{packet[:type]}"
  if packet[:value].nil?
    puts "#{istr}length_in_bits => #{packet[:length_in_bits]}"
    puts "#{istr}length => #{packet[:length]}"
    puts "#{istr}children ["
    packet[:children].each do |p|
      child_indent = indent+1
      cistr = ''.rjust(child_indent*2, ' ')
      puts "#{cistr}{"
      pretty_packet(p,child_indent+1)
      puts "#{cistr}}"
    end
    puts "#{istr}]"
  else
    puts "#{istr}value => #{packet[:value]}"
  end
end

def sum_versions (packet)
  sum = packet[:version]
  return sum if packet[:children].nil?
  packet[:children].map { |c| sum_versions(c) }.sum + sum
end

packets = {}
slurp($args[:file]).each do |hex_str|
  bin_str = to_bin(hex_str)
  packet, _ = parse_packet!(bin_str)
  puts "=============================" if $args[:verbose]
  packets[hex_str] = packet
end

packets.each do |k, v|
  puts k
  pretty_packet v
  puts "Version sum: #{sum_versions(v)}"
  puts
end
