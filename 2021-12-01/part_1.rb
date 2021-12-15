# frozen_string_literal: true

require 'pp'

if ARGV.length.zero?
  puts 'one file name pls, kthnx'
  exit
end

input_fh = File.open(ARGV[0])
input_str = input_fh.read
input_fh.close

inputs = input_str.split(/\n/).map(&:to_i)

increases = 0
last_number_seen = (2 << 100) # I hope that's practically close to infinite
inputs.each do |i|
  increases += 1 if i > last_number_seen
  last_number_seen = i
end

printf("Found %<inc>d increases in %<file>s\n", inc: increases, file: ARGV[0])
