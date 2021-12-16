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

def slurp_and_parse(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  size = input_str.split(/\n/).length
  linear = input_str.gsub(/\n/, '').chars.map(&:to_i)

  [linear, size]
end

def scale_up(graph, size, factor)
  staging = {}
  graph.each_with_index do |e, i|
    (0..(factor - 1)).each do |r|
      (0..(factor - 1)).each do |c|
        new_i = ((i % size) + (r * size)) + (((i / size) + (c * size)) * (size * factor))
        new_v = e + r + c
        new_v -= 9 if new_v > 9
        staging[new_i] = new_v
      end
    end
  end
  new_graph = staging.sort.map { |e| e[1] }
  [new_graph, size * factor]
end

def neighbors(node, size)
  neighbors = []
  neighbors.push(node - 1) unless (node % size).zero?
  neighbors.push(node + 1) unless (node % size) == (size - 1)
  neighbors.push(node - size) unless (node - size).negative?
  neighbors.push(node + size) unless (node + size) >= (size * size)
  neighbors
end

def dijkstra_spt(graph, size)
  distances = { 0 => { cost: 0, path: [], in_spt: false } }
  until graph.length == distances.select { |_, v| v[:in_spt] }.length
    puts "#{distances.select { |_, v| v[:in_spt] }.length}/#{graph.length} => #{(distances.select do |_, v|
                                                                                   v[:in_spt]
                                                                                 end.length / graph.length.to_f) * 100}"
    position, node = distances.reject { |_, v| v[:in_spt] }.min_by { |_, v| v[:cost] }
    node[:in_spt] = true
    neighbors(position, size).each do |i|
      neighbor_node = distances[i]
      next if !neighbor_node.nil? && neighbor_node[:in_spt]

      new_cost = node[:cost] + graph[i]
      new_path = node[:path].clone.push(i)
      if neighbor_node.nil? || neighbor_node[:cost] > new_cost
        distances[i] = { cost: new_cost, path: new_path, in_spt: false }
      end
    end
  end
  distances[(size * size) - 1][:path]
end

nodes, size = slurp_and_parse($args[:file])
nodes, size = scale_up(nodes, size, 5)
path = dijkstra_spt(nodes, size)
puts path.to_s
puts path.map { |i| nodes[i] }.sum
