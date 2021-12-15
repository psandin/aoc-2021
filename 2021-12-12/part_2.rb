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

def build_map(connections)
  network = {}
  connections.each do |e|
    e.each { |s| network[s] ||= [] }
    network[e[0]].push(e[1])
    network[e[1]].push(e[0])
  end
  network
end

$gpaths = []

def walk_paths(network, node = 'start', visited = {}, path = [])
  path.push(node)
  return $gpaths.push(path) if node == 'end'

  if node.match(/[[:lower:]]/)
    visited[node] ||= 0
    visited[node] += 1
    visited[node] = 3 if node == 'start'
  end

  network[node].each do |n|
    next if !visited[n].nil? && (
      ((visited[n] > 1) && !visited.values.include?(2)) ||
      ((visited[n]).positive? && visited.values.include?(2))
    )

    walk_paths(network, n, visited.clone, path.clone)
  end
end

network = build_map(slurp($args[:file]).map { |l| l.split('-') })
puts network
walk_paths(network)
$gpaths.each { |p| puts p.join(',') }
puts $gpaths.length.to_s
