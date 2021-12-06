require 'pp'
require 'optparse'
require 'term/ansicolor'
include Term::ANSIColor

$args = {}
OptionParser.new do |opts|
  opts.on('-f PATH', '--file PATH', String, :REQUIRED)
  opts.on('-v', '--verbose')
end.parse!(into: $args)
raise OptionParser::MissingArgument, "--file" if $args[:file].nil?

def slurp (path)
  input_fh = open path
  input_str = input_fh.read
  input_fh.close

  return input_str.split(/\n/)
end

$boards = []
$last_call = 0

def load_data
    lines = slurp($args[:file])
    $draws = lines.shift.split(/,/)
    while lines.length > 0
      load_board(lines)
    end
end

def load_board(data)
  blank = data.shift
  board = []
  puts "starting new board"
  0.upto(4).each {
    board.push(*data.shift.split.map { |e| { value: e, called:false } })
  }
  $boards.push(board)
  display_board(board)
  puts
end

def display_board(board)
  col = 0
  board.each do |e| 
    v = sprintf "%-2s ", e[:value]
    v = v.bold if e[:called]
    print v
    col += 1
    if(col > 4)
      col = 0
      puts
    end
  end
end

def call_number(num)
  $last_call = num
  $boards.each do |b|
    b.each do |c|
      if c[:value] == num
        c[:called] = true
      end
    end
  end
end

def check_board(board)
  0.upto(4).each do |i|
    rtc = 0
    ctc = 0
    0.upto(4).each do |j|
      rtc +=1 if board[5*i+j][:called]
      ctc +=1 if board[i+j*5][:called]
    end
    return true if rtc == 5 || ctc == 5
    rtc = 0
    ctc = 0
  end

  return false
end

def calc_board(board)
  board.map { |c| c[:called] ? 0 : c[:value].to_i }.sum * $last_call.to_i
end

load_data
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
puts
puts
display_board($boards[2])
puts check_board($boards[2])

call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
call_number($draws.shift)
puts
display_board($boards[2])
puts check_board($boards[2])

call_number($draws.shift)
puts
display_board($boards[2])
puts check_board($boards[2])
puts calc_board($boards[2])
