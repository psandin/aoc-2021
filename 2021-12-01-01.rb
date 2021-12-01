require 'pp'

if ARGV.length == 0
  puts "one file name pls, kthnx"
  exit
end

input_fh = open ARGV[0]
input_str = input_fh.read
input_fh.close

inputs = input_str.split(/\n/).map{|i| i.to_i}

# pp inputs

increases = 0
last_number_seen = (2 << 100) # I hope that's practically close to infinite
inputs.each { |i|
  if i > last_number_seen
    increases += 1
  end
  # printf "i: %d last_number_seen: %d\n", i, last_number_seen
  last_number_seen = i
}

printf "Found %d increases in %s\n", increases, ARGV[0]
