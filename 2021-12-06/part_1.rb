# frozen_string_literal: true

require 'pp'
require 'optparse'

$args = {
  birthage: 6,
  delay: 2,
  ticks: 80
}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-t TICKS', '--ticks TICKS', Integer)
  opts.on('-b BA', '--birthage BA', Integer)
  opts.on('-d BD', '--delay TICKS', Integer)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, '--file' if $args[:file].nil?

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/,/)
end

$fish_counter = 0
$days_between_births = $args[:birthage].to_i
$zero_cycle_delay = $args[:delay].to_i
$tick_count = $args[:ticks].to_i

puts "Days between births set to #{$days_between_births}" if $args[:verbose]
puts "Additional cycle zero delay set to #{$zero_cycle_delay}" if $args[:verbose]
puts "Tick count set to #{$tick_count}" if $args[:verbose]

# it's a 🐟 it makes more fish, but not very efficently
class Feeeesh
  def initialize(age: $days_between_births + $zero_cycle_delay + 1, school: [])
    @age = age
    @school = school
    @fish_id = $fish_counter
    $fish_counter += 1
    puts "Init ID: #{@fish_id} age: #{@age}" if $args[:verbose]
  end

  def id
    @fish_id
  end

  attr_reader :age

  def tick
    @age -= 1
    puts "Feeeesh ##{@fish_id} is now age: #{@age}" if $args[:verbose]
    return unless @age.negative?

    puts "Feeeesh ##{@fish_id} is making a baby 🤰" if $args[:verbose]
    babby = Feeeesh.new(school: @school)
    @school.push(babby)
    puts "Hello Feeeesh #{babby.id}" if $args[:verbose]
    @age = $days_between_births
  end
end

$feeeesh_school = []
def load_feeeesh
  base_pop = slurp($args[:file])
  base_pop.each do |f|
    $feeeesh_school.push(Feeeesh.new(age: f.to_i, school: $feeeesh_school))
  end
end

def dump_school
  puts $feeeesh_school.map(&:age).join(',') if $args[:verbose]
end

def global_tick
  $feeeesh_school.map(&:tick)
end

load_feeeesh
dump_school

1.upto($tick_count).each do
  global_tick
  dump_school
end

dump_school
puts "#{$feeeesh_school.length} total feeeesh"
