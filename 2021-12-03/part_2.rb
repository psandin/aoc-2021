# frozen_string_literal: true

require 'pp'
require 'optparse'

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, '--file' if $args[:file].nil?

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/\n/)
end

def find_max_item(data_set, col: 0)
  return data_set if data_set.length == 1

  res = sort_by_bit_value(data_set, col: col)
  if res['0'].length > res['1'].length
    find_max_item(res['0'], col: col + 1)
  else
    find_max_item(res['1'], col: col + 1)
  end
end

def find_min_item(data_set, col: 0)
  return data_set if data_set.length == 1

  res = sort_by_bit_value(data_set, col: col)
  if res['0'].length > res['1'].length
    find_min_item(res['1'], col: col + 1)
  else
    find_min_item(res['0'], col: col + 1)
  end
end

def sort_by_bit_value(data_set, col: 0)
  sets = {}
  data_set.each do |line|
    sets[line[col]] = [] if sets[line[col]].nil?
    sets[line[col]].push(line)
  end
  pp sets if $args[:verbose]
  sets
end

ox = find_max_item(slurp($args[:file]))
co = find_min_item(slurp($args[:file]))
oxi = ox.join.to_i(2)
coi = co.join.to_i(2)
puts "O2: #{ox} (#{oxi})" if $args[:verbose]
puts "CO2: #{co} (#{coi})" if $args[:verbose]
puts "Final: #{oxi * coi}"
