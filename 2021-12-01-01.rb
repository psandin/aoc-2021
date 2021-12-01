require 'pp'

if ARGV.length == 0
  puts "one file name pls, kthnx"
  exit
end

input_fh = open ARGV[0]
input_str = input_fh.read
input_fh.close

# pp input_str

inputs = input_str.split(/\n/).map{|i| i.to_i}

pp inputs