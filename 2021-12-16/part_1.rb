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

$depth = -1
$depth_pad = ''

def to_bin (hex)
  hex.hex.to_s(2).rjust(hex.size*4, '0')
end

def parse_literal! (bstr)
  last_digit =  false
  pbstr = ''
  until last_digit
    bdigit = bstr.slice!(0..4)
    last_digit = bdigit.slice!(0).to_i.zero?
    pbstr += bdigit
  end
  v = pbstr.to_i(2)
  [v, bstr]
end

def parse_sub_packets! (packet, remainder)
  packet[:children] = []
  packet[:length_in_bits] = remainder.slice!(0).to_i(2).zero?
  if packet[:length_in_bits]
    packet[:length] = remainder.slice!(0..14).to_i(2)
    sub_bits = remainder.slice!(0..(packet[:length]-1))
    #min packet length is 11
    until (sub_bits.length < 11)
      child, sub_bits = parse_packet!(sub_bits)
      packet[:children].push(child)
    end
  else
    packet[:length] = remainder.slice!(0..10).to_i(2)
    children_remaining = packet[:length]
    until (remainder.length < 11) || (children_remaining < 1)
      child, remainder = parse_packet!(remainder)
      packet[:children].push(child)
      children_remaining -= 1
    end
  end
  [packet, remainder]
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
  vbits = bpacket.slice!(0..2)
  tbits = bpacket.slice!(0..2)
  version = vbits.to_i(2)
  type = tbits.to_i(2)
  packet = {
    version: version,
    type: type
  }
  [packet, bpacket]
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

packets = {}
slurp($args[:file]).each do |hex_str|
  bin_str = to_bin(hex_str)
  packet, _ = parse_packet!(bin_str)
  packets[hex_str] = packet
end

packets.each do |k, v|
  puts k
  pretty_packet v
  puts
end
