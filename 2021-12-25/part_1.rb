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
    y: y_max,
    x: x_max,
    smap: smap,
  }
end

def tick(map)
  omap = map[:smap]
  (0..map[:x]).each do |x|
    (0..map[:y]).each do |y|
      if omap[[x,y]] == '>'

      end
    end
  end
end

def render_map(map)

end

raw_lines = slurp($args[:file])
puts raw_lines.to_s
sea_map = init_map(raw_lines)
puts sea_map.to_s
