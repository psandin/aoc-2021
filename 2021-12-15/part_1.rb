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
path = dijkstra_spt(nodes, width, height)
puts path.to_s
puts path.map { |i| nodes[i] }.sum
