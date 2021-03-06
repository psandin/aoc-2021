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

def parse_input(lines)
  chain = lines.shift
  first_char = chain[0]

  soup = Hash.new(0)
  (0..chain.length - 1).each { |i| soup[chain[i, 2]] += 1 }

  lines.shift

  rules = lines.map do |l|
    elements = l.split(/ -> /)
    {
      parent: elements[0],
      children: [
        elements[0][0] + elements[1],
        elements[1] + elements[0][1]
      ]
    }
  end

  [first_char, soup, rules]
end

def tick(soup, rules)
  children = Hash.new(0)
  rules.each do |rule|
    rule[:children].each { |child| children[child] += soup[rule[:parent]] }
  end
  children
end

def descibe_soup(soup, first_char)
  counts = Hash.new(0)
  counts[first_char] = 1
  soup.each { |k, v| counts[k.chars.last] += v }
  counts.sort_by { |_k, v| v }.to_h
end

first_char, soup, rules = parse_input(slurp($args[:file]))
puts rules.to_s
puts soup.to_s
(1..40).each do |i|
  soup = tick(soup, rules)
  puts "[#{i}] #{descibe_soup(soup, first_char)}"
end
counts = descibe_soup(soup, first_char)
puts "#{counts.values.first} [Smallest]"
puts "#{counts.values.last} [Largest]"
puts "#{counts.values.last - counts.values.first} [Difference]"
