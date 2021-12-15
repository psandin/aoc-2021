# frozen_string_literal: true

require 'pp'
require 'optparse'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, '--file' if $args[:file].nil?

def slurp(path)
  input_fh = File.open(path)
  input_str = input_fh.read
  input_fh.close

  input_str.split(/\n/)
end

$boards = []
$last_call = 0

def load_data
  lines = slurp($args[:file])
  $draws = lines.shift.split(/,/)
  load_board(lines) while lines.length.positive?
end

def load_board(data)
  data.shift
  board = []
  puts 'starting new board' if $args[:verbose]
  0.upto(4).each do
    board.push(*data.shift.split.map { |e| { value: e, called: false } })
  end
  $boards.push(board)
  display_board(board) if $args[:verbose]
  puts if $args[:verbose]
end

def display_board(board)
  col = 0
  board.each do |e|
    v = format '%-2s ', e[:value]
    v = v.bold if e[:called]
    print v
    col += 1
    if col > 4
      col = 0
      puts
    end
  end
end

def call_number(num)
  puts "Calling #{num}" if $args[:verbose]
  $last_call = num
  $boards.each do |b|
    b.each do |c|
      c[:called] = true if c[:value] == num
    end
  end
end

def check_board(board)
  0.upto(4).each do |i|
    rtc = 0
    ctc = 0
    0.upto(4).each do |j|
      rtc += 1 if board[(5 * i) + j][:called]
      ctc += 1 if board[i + (j * 5)][:called]
    end
    return true if rtc == 5 || ctc == 5

    rtc = 0
    ctc = 0
  end

  false
end

def calc_board(board)
  board.map { |c| c[:called] ? 0 : c[:value].to_i }.sum * $last_call.to_i
end

load_data

while $boards.length > 1
  call_number($draws.shift)
  $boards.each do |b|
    $boards.delete(b) if check_board(b)
  end
end

call_number($draws.shift) until check_board($boards[0])

display_board($boards[0])
puts calc_board($boards[0])
