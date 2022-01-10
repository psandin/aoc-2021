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

def init_map(lines)
  y_max = lines.count
  x_max = lines[0].chars.count
  smap = {}
  lines.each_with_index do |l, y|
    l.chars.each_with_index do |c,x|
      smap[[x,y]] = c
    end
  end
  return {
    y: y_max - 1,
    x: x_max - 1,
    smap: smap,
  }
end

def tick(map)
  u = 0
  u += east_tick(map)
  u += south_tick(map)
end

def east_tick(map)
  omap = map[:smap]
  updates = []
  (0..map[:x]).each do |x|
    (0..map[:y]).each do |y|
      if omap[[x,y]] == '>'
        nx = x + 1
        nx = 0 if nx > map[:x]
        if omap[[nx,y]] == '.'
          updates.push([[x,y],'.'])
          updates.push([[nx,y],'>'])
        end
      end
    end
  end
  updates.each {|u| omap[u[0]] = u[1] }
  updates.count / 2
end

def south_tick(map)
  omap = map[:smap]
  updates = []
  (0..map[:x]).each do |x|
    (0..map[:y]).each do |y|
      if omap[[x,y]] == 'v'
        ny = y + 1
        ny = 0 if ny > map[:y]
        if omap[[x,ny]] == '.'
          updates.push([[x,y],'.'])
          updates.push([[x,ny],'v'])
        end
      end
    end
  end
  updates.each {|u| omap[u[0]] = u[1] }
  updates.count / 2
end

def render_map(map)
  omap = map[:smap]
  (0..map[:y]).each do |y|
    (0..map[:x]).each do |x|
      print omap[[x,y]]
    end
    puts
  end
end

raw_lines = slurp($args[:file])
puts raw_lines.to_s
sea_map = init_map(raw_lines)
puts sea_map.to_s
render_map(sea_map)
updates = 1
rounds = 0
until updates.zero?
  rounds +=1
  updates =  tick(sea_map)
  render_map(sea_map)
  puts updates
end
puts rounds