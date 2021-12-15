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
  lines.shift
  subs = lines.map do |l|
    %i[find insert].zip(l.split(/ -> /)).to_h
  end
  [chain, subs]
end

def find_subs(subs, chain)
  actions = []
  subs.each do |s|
    (0..chain.length)
      .select { |i| chain[i, 2] == s[:find] }
      .each do |i|
        actions.push({ position: i, value: s[:insert], rule: s })
      end
  end
  actions.sort_by { |a| a[:position] }
end

def execute_subs(chain, actions)
  actions.each_with_index do |action, i|
    puts "Doing action #{action}"
    head = chain[0, action[:position] + 1 + i]
    tail = chain[action[:position] + 1 + i, chain.length]
    chain = head + action[:value] + tail
  end
  chain
end

def describe_chain(chain)
  counts = {}
  chain.chars.each do |c|
    counts[c] = 0 if counts[c].nil?
    counts[c] += 1
  end
  counts.sort_by { |_k, v| v }.to_h
end

chain, subs = parse_input(slurp($args[:file]))
(1..1).each do |i|
  actions = find_subs(subs, chain)
  chain = execute_subs(chain, actions)
  # puts "Round \##{i}"
  # puts "#{chain}"
  # puts "#{chain.length}"
  puts "[#{i}p1] #{describe_chain(chain)}"
end
