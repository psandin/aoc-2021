require 'pp'

if ARGV.length == 0
  puts "one file name pls, kthnx"
  exit
end

input_fh = open ARGV[0]
input_str = input_fh.read
input_fh.close

inputs = input_str.split(/\n/).map{|i| i.to_i}

slice_size = 3

if slice_size > inputs.length
  puts 'Well this is bad, gtfo'
  exit
end

slice_count = inputs.length - slice_size
blocks = (0..slice_count).map { |i|
  inputs.slice(i, slice_size).sum
}

increases = 0
last_number_seen = (2 << 100) # I hope that's practically close to infinite
blocks.each { |i|
  if i > last_number_seen
    increases += 1
  end
  last_number_seen = i
}

printf "Found %d increases in %s with window size %d\n", increases, ARGV[0], slice_size
