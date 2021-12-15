# frozen_string_literal: true

require 'pp'
require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-s NUM', '--size NUM', Integer, :REQUIRED)
end.parse!(into: params)
raise OptionParser::MissingArgument, '--file' if params[:file].nil?
raise OptionParser::MissingArgument, '--size' if params[:size].nil?

def slurp_array(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/\n/).map(&:to_i)
end

def bucket_inputs(data, slice_size)
  if slice_size >= data.length
    puts 'Slice size exceeds file size 💀'
    exit(-1)
  end

  slice_count = data.length - slice_size
  (0..slice_count).map do |i|
    data.slice(i, slice_size).sum
  end
end

def count_increases(data)
  increases = 0
  last_number_seen = (2 << 100) # I hope that's practically close to infinite
  data.each do |i|
    increases += 1 if i > last_number_seen
    last_number_seen = i
  end
  increases
end

ss = params[:size]
input_path = params[:file]
inputs = slurp_array(input_path)
blocks = bucket_inputs(inputs, ss)
result = count_increases(blocks)

printf "Found %<inc>d increases in %<file>s with window size %<win_size>d\n",
       inc: result, file: input_path, win_size: ss
