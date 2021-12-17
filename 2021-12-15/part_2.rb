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

# They weren't bluffing about using a priority queue, so we shall
class PQueue
  def initialize
    @storage = Hash.new { |h, k| h[k] = [] }
  end

  def push (item, priority)
    @storage[priority].push(item)
  end

  def next
    priority, bucket = @storage.min_by {|k,_| k }
    return nil if bucket.nil?
    @storage.delete(priority) if bucket.length == 1
    bucket.shift
  end

  def has_items?
    !@storage.first.nil?
  end
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
  s = Math.sqrt(goal + 1)
  x = (start / s).to_i
  y = (start % s).to_i
  Math.sqrt((((s - y)**2 + (s - x)**2))).round * 2
end

def calc_priority(new_cost, index, size)
  goal = (size**2)-1
  m = manhattan(index, goal)
  new_cost + m
end

def a_star(graph, size)
  goal = (size**2) - 1
  candidate_queue = PQueue.new()
  candidate_queue.push(0, 0)
  path_data = Hash.new do |h, k|
    h[k] = Hash.new()
    h[k] = { cost:2**32, path: [], finalized: false }
  end
  path_data[0] = { cost: 0, path: [], finalized: false }

  iterations = 0
  while candidate_queue.has_items?
    current_index = candidate_queue.next
    current_data = path_data[current_index]
    next if current_data[:finalized]
    current_data[:finalized] = true

    neighbors(current_index, size).each do |i|
      new_cost = current_data[:cost] + graph[i]
      neighbor_node = path_data[i]

      next if neighbor_node[:finalized]
      next if neighbor_node[:cost] < new_cost

      path_data[i] = {
        cost: new_cost,
        path: current_data[:path].clone.push(i),
        finalized: false
      }

      candidate_queue.push(i, calc_priority(new_cost, i, size))
    end

    iterations += 1
    puts "#{iterations} / #{goal} | #{((iterations.to_f / goal)*100).round(3)}%"

    break if current_index == graph.length - 1
  end
  path_data[goal][:path]
end

nodes, size = slurp_and_parse($args[:file])
nodes, size = scale_up(nodes, size, 5)
path = a_star(nodes, size)
puts path.to_s
puts path.map { |i| nodes[i] }.sum
