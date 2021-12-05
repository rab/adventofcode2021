# --- Day 5: Hydrothermal Venture ---
# You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce
# large, opaque clouds, so it would be best to avoid them if possible.
#
# They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents
# (your puzzle input) for you to review. For example:
#
# 0,9 -> 5,9
# 8,0 -> 0,8
# 9,4 -> 3,4
# 2,2 -> 2,1
# 7,0 -> 7,4
# 6,4 -> 2,0
# 0,9 -> 2,9
# 3,4 -> 1,4
# 0,0 -> 8,8
# 5,5 -> 8,2
#
# Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the
# coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These
# line segments include the points at both ends. In other words:
#
#
# An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
# An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
#
# For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.
#
# So, the horizontal and vertical lines from the above list would produce the following diagram:
#
# .......1..
# ..1....1..
# ..1....1..
# .......1..
# .112111211
# ..........
# ..........
# ..........
# ..........
# 222111....
#
# In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is
# shown as the number of lines which cover that point or . if no line covers that point. The
# top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the
# overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.
#
# To avoid the most dangerous areas, you need to determine the number of points where at least two
# lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a
# total of 5 points.
#
# Consider only horizontal and vertical lines. At how many points do at least two lines overlap?
#

# --- Part Two ---
# Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture;
# you need to also consider diagonal lines.

# Because of the limits of the hydrothermal vent mapping system, the lines in your list will only
# ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

# An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
# An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
# Considering all lines from the above example would now produce the following diagram:

# 1.1....11.
# .111...2..
# ..2.1.111.
# ...1.2.2..
# .112313211
# ...1.2....
# ..1...1...
# .1.....1..
# 1.......1.
# 222111....

# You still need to determine the number of points where at least two lines overlap. In the above
# example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

# Consider all of the lines. At how many points do at least two lines overlap?

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

require 'pry' if debugging

if testing || debugging
  input = <<~END
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
  END
else
  puts "solving day #{day} from input"
end

class Line
  attr_accessor :x1,:y1, :x2,:y2
  def initialize(segment)
    @x1,@y1, @x2,@y2 = segment.split(/,| -> /).map(&:to_i)
  end
  def horz?
    self.y1 == self.y2 && ' H'
  end
  def vert?
    self.x1 == self.x2 && ' V'
  end
  def part1?
    self.horz? || self.vert?
  end
  def to_s
    "%3d,%3d -> %3d,%3d%s"%[@x1,@y1, @x2,@y2, self.part1? || ' D']
  end
end

class Grid
  def initialize
    @grid = Hash.new(0) # indexed by [x,y]
  end

  def draw(line)
    if line.horz?
      Range.new(*[line.x1,line.x2].sort).each do |x|
        @grid[[x,line.y1]] += 1
      end
    elsif line.vert?
      Range.new(*[line.y1,line.y2].sort).each do |y|
        @grid[[line.x1,y]] += 1
      end
    else                        # oblique
      dx = line.x1 < line.x2 ? +1 : -1
      dy = line.y1 < line.y2 ? +1 : -1
      x = line.x1 - dx
      y = line.y1 - dy
      begin
        x += dx
        y += dy
        @grid[[x,y]] += 1
      end until x == line.x2 && y == line.y2
    end
  end

  def count
    sum = 0
    if block_given?
      @grid.values.each do |point|
        if yield point
          sum += 1
        end
      end
    else
      @grid.values.count
    end
    sum
  end
  def to_s
    str = ''
    x0,y0 = 0,0
    xn = @grid.keys.map(&:first).max
    yn = @grid.keys.map(&:last ).max
    (y0..yn).each do |y|
      (x0..xn).each do |x|
        str << (@grid[[x,y]].nonzero? || ' ').to_s
      end
      str << "\n"
    end
    str
  end
end

grid1 = Grid.new
grid2 = Grid.new
input.each_line(chomp: true) do |line|
  puts line if debugging
  l = Line.new(line)
  puts l if debugging
  grid2.draw l
  next unless l.part1?
  grid1.draw l
end
binding.pry if debugging
puts grid1 if testing || debugging
overlaps1 = grid1.count {|point| point >= 2 }
puts "Part 1: #{overlaps1}"
if testing || debugging
  expected = 5
  if overlaps1 == expected
    puts "GOOD"
  else
    puts "Expected #{expected}"
    exit 1
  end
end

binding.pry if debugging
puts grid2 if testing || debugging
overlaps2 = grid2.count {|point| point >= 2 }
puts "Part 2: #{overlaps2}"
if testing || debugging
  expected = 12
  if overlaps2 == expected
    puts "GOOD"
  else
    puts "Expected #{expected}"
    exit 1
  end
end
