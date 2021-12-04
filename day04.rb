# --- Day 4: Giant Squid ---
# You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that
# you can't see any sunlight. What you can see, however, is a giant squid that has attached itself
# to the outside of your submarine.
#
# Maybe it wants to play bingo?
#
# Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen
# at random, and the chosen number is marked on all boards on which it appears. (Numbers may not
# appear on all boards.) If all numbers in any row or any column of a board are marked, that board
# wins. (Diagonals don't count.)
#
# The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass
# the time. It automatically generates a random order in which to draw numbers and a random set of
# boards (your puzzle input). For example:
#
# 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
#
# 22 13 17 11  0
#  8  2 23  4 24
# 21  9 14 16  7
#  6 10  3 18  5
#  1 12 20 15 19
#
#  3 15  0  2 22
#  9 18 13 17  5
# 19  8  7 25 23
# 20 11 10 24  4
# 14 21 16 12  6
#
# 14 21 17 24  4
# 10 16 15  9 19
# 18  8 23 26 20
# 22 11 13  6  5
#  2  0 12  3  7
#
# After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the
# boards are marked as follows (shown here adjacent to each other to save space):
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# Finally, 24 is drawn:
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# At this point, the third board wins because it has at least one complete row or column of marked
# numbers (in this case, the entire top row is marked: 14 21 17 24 4).
#
# The score of the winning board can now be calculated. Start by finding the sum of all unmarked
# numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that
# was just called when the board won, 24, to get the final score, 188 * 24 = 4512.
#
# To guarantee victory against the giant squid, figure out which board will win first. What will
# your final score be if you choose that board?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2021)

while ARGV[0]
  case ARGV.shift
  when 'test'
    testing = true
  when 'debug'
    debugging = true
  end
end

if testing
  input = <<~END
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
  END
else
  puts "solving day #{day} from input"
end

require 'term/ansicolor'
require 'pry'

class Board
  include Term::ANSIColor

  def initialize(lines)
    @board = Array.new(5)
    lines.each.with_index do |row,r|
      @board[r] = row.strip.split(' ').map {|col| [col.to_i, nil] }
    end
  end

  def mark(number)
    return if @already_won
    @last = number
    @board.each do |row|
      if (col = row.assoc(number))
        col[1] = true
        return
      end
    end
  end

  def wins?
    return true if @already_won
    wins = false
    # row?
    @board.each.with_index do |row,r|
      if row.all? {|_col,marked| marked}
        wins = "row #{r}"
        row.each {|col| col[1] = col[0] }
      end
    end
    return wins if wins
    #col?
    # binding.pry if @last == 13
    @board.size.times do |c|
      if @board.map {|row| row[c] }.all? {|_col,marked| marked }
        wins = "col #{c}"
        @board.each {|row| row[c][1] = row[c][0] }
      end
    end
    wins
  end

  def stop_playing!
    @already_won = true
  end

  def just_won?(number)
    @already_won && number == @last
  end

  def score
    unmarked = @board.flat_map {|row| row.flat_map {|col,marked| col unless marked }}.compact.sum
    print " (#{unmarked} * #{@last}) "
    unmarked * (@last || 0)
  end

  def to_s
    str = +"\n"
    str << "Won on #{@last}\n" if @already_won
    @board.each do |row|
      row.each do |(col,marked)|
        if marked
          str << cyan << " %2d"%[col] << reset
        else
          str << " %2d"%[col]
        end
      end
      str << "\n"
    end
    str
  end
end

calls = nil
state = :start
boards = []
saved = []
input.each_line(chomp: true) do |line|
  puts line if debugging
  case state
  when :start
    calls = line.split(',').map(&:to_i)
    state = :board
  when :board
    next if line.empty?
    saved << line
    if saved.size == 5
      boards << Board.new(saved)
      saved = []
    end
  end
end
unless saved.empty?
  $stderr.puts "extra lines?"
  $stderr.p saved
end

puts calls.inspect, boards if testing

Color = Object.new.extend Term::ANSIColor

last_call = nil
winning = nil
calls.each do |call|
  last_call = call
  print Color.bold,Color.red,call,Color.reset,"\n" if testing
  boards.each do |board|
    board.mark call
    puts board, board.score if testing
  end
  puts "-"*20 if testing
  if !winning && boards.any?(&:wins?)
    winning = (winner = boards.select(&:wins?)).map(&:score)
    winner.each &:stop_playing!
  end
  boards.each do |board|
    board.stop_playing! if board.wins?
  end
  break if boards.all?(&:wins?)
end

puts "Part 1: winning score #{winning}"

last_winner = boards.detect {|board| board.just_won?(last_call) }

puts "Part 2: last winner #{last_winner.score}"
