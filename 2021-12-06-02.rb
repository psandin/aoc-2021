require 'pp'
require 'optparse'

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-t TICKS', '--ticks TICKS', Integer)
  opts.on('-b BA', '--birthage BA', Integer)
  opts.on('-d BD', '--delay TICKS', Integer)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, "--file" if $args[:file].nil?

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/,/)
end

$fish_counter = 0
$days_between_births = $args.key?(:birthage) ? $args[:birthage].to_i : 6
$zero_cycle_delay = $args.key?(:delay) ? $args[:delay].to_i : 2
$tick_count = $args.key?(:ticks)  ? $args[:ticks].to_i : 80

puts "Days between births set to #{$days_between_births}" if $args[:verbose]
puts "Additional cycle zero delay set to #{$zero_cycle_delay}" if $args[:verbose]
puts "Tick count set to #{$tick_count}" if $args[:verbose]

$feeeesh_school = []

def load_feeeesh
  $feeeesh_school = 0.upto($zero_cycle_delay + $days_between_births).map { 0 }
  base_pop = slurp($args[:file])
  base_pop.each { |f|
   $feeeesh_school[f.to_i] += 1
  }
end

def dump_school
  puts "#{$feeeesh_school}" if $args[:verbose]
end

def global_tick
  birthing = $feeeesh_school.shift
  $feeeesh_school[$days_between_births] += birthing
  $feeeesh_school.push(birthing)
end

load_feeeesh
dump_school

1.upto($tick_count).each {
  global_tick
  dump_school
}

total_feeesh = $feeeesh_school.each.sum
puts "#{total_feeesh} total feeeesh"
