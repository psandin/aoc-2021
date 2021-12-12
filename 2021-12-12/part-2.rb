require 'pp'
require 'optparse'
require 'term/ansicolor'
include Term::ANSIColor

$args = {
  file: File.dirname(__FILE__) + "/input"
}
OptionParser.new do |opts|
  opts.on('-s', '--simple') do
    $args[:file] = File.dirname(__FILE__) + "/input.simple"
  end
  opts.on('-f PATH', '--file PATH', String) do |path|
    $args[:file] = path
  end
  opts.on('-v', '--verbose') do
    $args[:verbose] = true
  end
end.parse!

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/)
end

def build_map(connections)
  network = {}
  connections.each do |e|
    e.each do |s|
      if network[s].nil?
        network[s] = {
          big: (s.match /[[:upper:]]/) ? true : false,
          neighbors: []
        }
      end
    end
    network[e[0]][:neighbors].push(e[1])
    network[e[1]][:neighbors].push(e[0])
  end
  return network
end

$gpaths = []

def walk_paths(network, node: 'start', visited: {}, path: [], two_burned: '')
  path.push(node)
  if node == 'end'
    $gpaths.push(path)
    return
  end
  local_node = network[node]
  prefix = path.join(',')
  unless local_node[:big]
    visited[node] = 0 if visited[node].nil?
    visited[node] += 1
    if visited[node] > 1 and two_burned == ''
      two_burned = prefix.clone
    end
    visited[node] += 1 if node == "start"
  end

  local_node[:neighbors].each do |n|
    if not visited[n].nil? and ((visited[n] > 1 and two_burned == '') or (visited[n] > 0 and two_burned != ''))
      next
    end
    walk_paths(network, node: n, visited: visited.clone, path: path.clone, two_burned: two_burned.clone)
  end
end

raw_lines = slurp($args[:file]).map { |l| l.split('-')}
network = build_map(raw_lines)
puts network
walk_paths(network)
$gpaths.each do |p|
  puts  p.join(',')
end
puts "#{$gpaths.length}"





