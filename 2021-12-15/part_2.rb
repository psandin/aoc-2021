# frozen_string_literal: true

require 'pp'
require 'optparse'

require 'term/ansicolor'

class String
  include Term::ANSIColor
end


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
        staging[new_i] = e + r + c
        staging[new_i] -= 9 if staging[new_i] > 9
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

def manhattan (start, goal)
  # return 0
  # puts "==> manhattan(#{start}, #{goal})"
  s = Math.sqrt(goal + 1)
  x = (start / s).to_i
  y = (start % s).to_i
  # puts "s => #{s}"
  # puts "x => #{x}"
  # puts "y => #{y}"
  Math.sqrt((((s - y)**2 + (s - x)**2))).round * 2
end

def render_search_area(searched, graph)
  # puts searched.to_s
  figs = 5
  s = Math.sqrt(graph.length)
  (0..(s-1)).each do |y|
    (0..(s-1)).each do |x|
      i = ((s * y) + x).to_i
      # puts "pulling data about #{i}"
      node = searched[i]
      # puts "Found #{node}"
      if node.nil?
        print " ".rjust(figs+1,'-')
      else
        cost = node[:cost] + manhattan(i, graph.length - 1) 
        v = "#{cost.to_s.rjust(figs, '0')} "
        v = v.bold if node[:in_spt]
        print v
      end
    end
    puts
  end
  puts
end


def dijkstra_spt(graph, size)
  distances = { 0 => { cost: 0, path: [], in_spt: false } }
  nodes_touched = 0
  until graph.length == distances.select { |_, v| v[:in_spt] }.length
    found = distances.select { |_, v| v[:in_spt] }.length
    to_find = distances.reject { |_, v| v[:in_spt] }
    best_candidates = to_find.sort_by {|k, v| manhattan(k, graph.length - 1) }[0, (graph.length * 1).to_i]
    position, node = best_candidates.min_by { |k, v| v[:cost]}
    if (found % 100).zero?
      print "#{found}/#{graph.length} => #{((found / graph.length.to_f) * 100).round(3)}% "
      m = manhattan(position, graph.length - 1)
      mm = manhattan(0, graph.length - 1)
      mp = (((mm - m.to_f)/mm)*100).round(3)
      puts  "m: #{m} mp: #{mp}%"
    end
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
    nodes_touched += 1
    # render_search_area(distances, graph)
    break if position == graph.length - 1
  end
  puts "Touched #{nodes_touched} of #{graph.length} nodes (#{((nodes_touched.to_f/graph.length)*100).round(3)}%)"
  distances[(size * size) - 1][:path]
end

# puts "m(0,99)  => #{manhattan(0,99)}"
# puts "m(1,99)  => #{manhattan(1,99)}"
# puts "m(10,99) => #{manhattan(10,99)}"
# puts
# puts "m(99,99) => #{manhattan(99,99)}"

# exit

# (0..9).each do |y|
#   (0..9).each do |x|
#     i = (y*10)+x
#     print "#{manhattan(i, 99).to_s.rjust(3, '0')} "
#   end
#   puts
# end

# exit

nodes, size = slurp_and_parse($args[:file])
nodes, size = scale_up(nodes, size, 5)
path = dijkstra_spt(nodes, size)
puts path.to_s
puts path.map { |i| nodes[i] }.sum
