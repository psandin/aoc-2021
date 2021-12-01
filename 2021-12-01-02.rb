require 'pp'
require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-s NUM', '--size NUM', Integer, :REQUIRED)
end.parse!(into: params)
raise OptionParser::MissingArgument, "--file" if params[:file].nil?
raise OptionParser::MissingArgument, "--size" if params[:size].nil?

def slurp_array (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/).map{|i| i.to_i}
end

def bucket_inputs (data, slice_size)
  if slice_size > data.length
    puts 'Well this is bad, gtfo'
    exit
  end

  slice_count = data.length - slice_size
  blocks = (0..slice_count).map { |i|
    data.slice(i, slice_size).sum
  }
end

def count_increases (data)
  increases = 0
  last_number_seen = (2 << 100) # I hope that's practically close to infinite
  data.each { |i|
    if i > last_number_seen
      increases += 1
    end
    last_number_seen = i
  }
  return increases
end

ss = params[:size]
input_path = params[:file]
inputs = slurp_array(input_path)
blocks = bucket_inputs(inputs, ss)
result = count_increases(blocks)

printf "Found %d increases in %s with window size %d\n", result, input_path, ss
