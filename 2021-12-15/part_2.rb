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

  height = input_str.split(/\n/).length
  width = input_str.split(/\n/).first.chars.length
  linear = input_str.gsub(/\n/, '').chars.map(&:to_i)

  [linear, width, height]
end

def scale_up(graph, width, height, factor)
  staging = {}
  graph.each_with_index do |e, i|
    (0..(factor - 1)).each do |r|
      (0..(factor - 1)).each do |c|
        new_i = ((i % width) + (r * width)) + (((i / width) + (c * width)) * (width * factor))
        new_v = e + r + c
        new_v -= 9 if new_v > 9
        staging[new_i] = new_v
      end
    end
  end
  new_graph = staging.sort.map { |e| e[1] }
  [new_graph, width * factor, height * factor]
end

def neighbors(node, width, height)
  neighbors = []
  neighbors.push(node - 1) unless (node % width).zero?
  neighbors.push(node + 1) unless (node % width) == (width - 1)
  neighbors.push(node - width) unless (node - width).negative?
  neighbors.push(node + width) unless (node + width) >= (width * height)
  neighbors
end

def dijkstra_spt(graph, width, height)
  distances = { 0 => { cost: 0, path: [], in_spt: false } }
  until graph.length == distances.select { |_, v| v[:in_spt] }.length
    puts "#{distances.select { |_, v| v[:in_spt] }.length}/#{graph.length} => #{(distances.select do |_, v|
                                                                                   v[:in_spt]
                                                                                 end.length / graph.length.to_f) * 100}"
    position, node = distances.reject { |_, v| v[:in_spt] }.min_by { |_, v| v[:cost] }
    node[:in_spt] = true
    neighbors(position, width, height).each do |i|
      neighbor_node = distances[i]
      next if !neighbor_node.nil? && neighbor_node[:in_spt]

      new_cost = node[:cost] + graph[i]
      new_path = node[:path].clone.push(i)
      if neighbor_node.nil? || neighbor_node[:cost] > new_cost
        distances[i] = { cost: new_cost, path: new_path, in_spt: false }
      end
    end
  end
  distances[(width * height) - 1][:path]
end

nodes, width, height = slurp_and_parse($args[:file])
nodes, width, height = scale_up(nodes, width, height, 5)
path = dijkstra_spt(nodes, width, height)
puts path.to_s
puts path.map { |i| nodes[i] }.sum
