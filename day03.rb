# --- Day 3: Binary Diagnostic ---
# The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic
# report just in case.
#
# The diagnostic report (your puzzle input) consists of a list of binary numbers which, when
# decoded properly, can tell you many useful things about the conditions of the submarine. The
# first parameter to check is the power consumption.
#
# You need to use the binary numbers in the diagnostic report to generate two new binary numbers
# (called the gamma rate and the epsilon rate). The power consumption can then be found by multiplying the gamma
# rate by the epsilon rate.
#
# Each bit in the gamma rate can be determined by finding the most common bit in the corresponding
# position of all numbers in the diagnostic report. For example, given the following diagnostic
# report:
#
# 00100
# 11110
# 10110
# 10111
# 10101
# 01111
# 00111
# 11100
# 10000
# 11001
# 00010
# 01010
#
# Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the
# most common bit is 1, the first bit of the gamma rate is 1.
#
# The most common second bit of the numbers in the diagnostic report is 0, so the second bit of
# the gamma rate is 0.
#
# The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so
# the final three bits of the gamma rate are 110.
#
# So, the gamma rate is the binary number 10110, or 22 in decimal.
#
# The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common
# bit from each position is used. So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate
# (22) by the epsilon rate (9) produces the power consumption, 198.
#
# Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then
# multiply them together. What is the power consumption of the submarine? (Be sure to represent
# your answer in decimal, not binary.)
#

# --- Part Two ---
# Next, you should verify the life support rating, which can be determined by multiplying the
# oxygen generator rating by the CO2 scrubber rating.
#
# Both the oxygen generator rating and the CO2 scrubber rating are values that can be found in
# your diagnostic report - finding them is the tricky part. Both values are located using a
# similar process that involves filtering out values until only one remains. Before searching for
# either rating value, start with the full list of binary numbers from your diagnostic report and
# consider just the first bit of those numbers. Then:
#
# - Keep only numbers selected by the bit criteria for the type of rating value for which you are
#   searching. Discard numbers which do not match the bit criteria.
# - If you only have one number left, stop; this is the rating value for which you are searching.
# - Otherwise, repeat the process, considering the next bit to the right.
#
# The bit criteria depends on which type of rating value you want to find:
#
# - To find oxygen generator rating, determine the most common value (0 or 1) in the current bit
#   position, and keep only numbers with that bit in that position. If 0 and 1 are equally common,
#   keep values with a 1 in the position being considered.
# - To find CO2 scrubber rating, determine the least common value (0 or 1) in the current bit
#   position, and keep only numbers with that bit in that position. If 0 and 1 are equally common,
#   keep values with a 0 in the position being considered.
#
# For example, to determine the oxygen generator rating value using the same example diagnostic
# report from above:
#
# - Start with all 12 numbers and consider only the first bit of each number.
# - There are more 1 bits (7) than 0 bits (5), so keep only the 7 numbers with a 1 in the first
#   position: 11110, 10110, 10111, 10101, 11100, 10000, and 11001.
# - Then, consider the second bit of the 7 remaining numbers: there are more 0 bits (4) than 1
#   bits (3), so keep only the 4 numbers with a 0 in the second position: 10110, 10111, 10101, and
#   10000.
# - In the third position, three of the four numbers have a 1, so keep those three: 10110, 10111,
#   and 10101.
# - In the fourth position, two of the three numbers have a 1, so keep those two: 10110 and 10111.
# - In the fifth position, there are an equal number of 0 bits and 1 bits (one each). So, to find
#   the oxygen generator rating, keep the number with a 1 in that position: 10111.
# - As there is only one number left, stop; the oxygen generator rating is 10111, or 23 in decimal.
#
# Then, to determine the CO2 scrubber rating value from the same example above:
#
# - Start again with all 12 numbers and consider only the first bit of each number. There are
#   fewer 0 bits (5) than 1 bits (7), so keep only the 5 numbers with a 0 in the first position:
#   00100, 01111, 00111, 00010, and 01010.
# - Then, consider the second bit of the 5 remaining numbers: there are fewer 1 bits (2) than 0
#   bits (3), so keep only the 2 numbers with a 1 in the second position: 01111 and 01010.
# - In the third position, there are an equal number of 0 bits and 1 bits (one each). So, to find
#   the CO2 scrubber rating, keep the number with a 0 in that position: 01010.
# - As there is only one number left, stop; the CO2 scrubber rating is 01010, or 10 in decimal.

# Finally, to find the life support rating, multiply the oxygen generator rating (23) by the CO2
# scrubber rating (10) to get 230.

# Use the binary numbers in your diagnostic report to calculate the oxygen generator rating and
# CO2 scrubber rating, then multiply them together. What is the life support rating of the
# submarine? (Be sure to represent your answer in decimal, not binary.)
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

if testing || debugging
  input = <<~END
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
  END
else
  puts "solving day #{day} from input"
end

class BitCounter
  def initialize(testing: nil, debugging: nil)
    @testing = testing
    @debugging = debugging
    @bit_freq = []
    @values = []
  end
  def <<(value)
    int = value.to_i(2)
    @values << value            # or int?
    value.size.times do |bit|
      @bit_freq[bit] ||= [0,0]
      @bit_freq[bit][int[bit]] += 1
    end
  end
  def epsilon
    @bit_freq.map {|pos| pos.index(pos.min).to_s }.reverse.join.to_i(2)
  end
  def gamma
    @bit_freq.map {|pos| pos.index(pos.max).to_s }.reverse.join.to_i(2)
  end
  def power_consumption
    epsilon * gamma
  end
  def o2
    remaining_values = @values.dup
    if @debugging
      p @values
    end
    pos = 0
    right = @values.first.size - 1
    while remaining_values.size > 1
      if @debugging
        p remaining_values
      end
      if pos > right
        $stderr.puts "Crap! didn't get to one value: #{remaining_values.inspect}"
        exit 2
      end
      zeros, ones = bit_counts(remaining_values, pos)
      if @debugging
        puts %w[zeros ones].zip([zeros, ones])
      end

      keeps = zeros > ones ? '0' : '1'

      remaining_values.keep_if {|val| val[pos] == keeps }
      pos += 1
    end
    if @debugging
      p remaining_values
    end
    remaining_values[0].to_i(2)
  end

  def co2
    remaining_values = @values.dup
    if @debugging
      p @values
    end
    pos = 0
    right = @values.first.size - 1
    while remaining_values.size > 1
      if @debugging
        p remaining_values
      end
      if pos > right
        $stderr.puts "Crap! didn't get to one value: #{remaining_values.inspect}"
        exit 2
      end
      zeros, ones = bit_counts(remaining_values, pos)
      if @debugging
        puts %w[zeros ones].zip([zeros, ones])
      end

      keeps = zeros > ones ? '1' : '0'

      remaining_values.keep_if {|val| val[pos] == keeps }
      pos += 1
    end
    if @debugging
      p remaining_values
    end
    remaining_values[0].to_i(2)
  end

  def life_support
    o2 * co2
  end

  private def bit_counts(values, pos)
    if @debugging
      puts "bit_counts(#{values.inspect}, #{pos})"
    end
    values.partition {|val| val[pos] == '0' }.map(&:count)
  end
end

bits = BitCounter.new(testing: testing, debugging: debugging)
input.each_line(chomp: true) do |line|
  puts line if debugging
  bits << line
end

puts "Part 1: epsilon: #{bits.epsilon} gamma: #{bits.gamma}, power: #{bits.power_consumption}"
if testing
  expected = [9,22,198]
  if [:epsilon, :gamma, :power_consumption].map {|v| bits.public_send(v)} == expected
    puts "GOOD"
  else
    puts "Expected to be #{expected.inspect}"
  end
end

puts "Part 2: o2: #{bits.o2} co2: #{bits.co2} life_support: #{bits.life_support}"
if testing || debugging
  expected = [23, 10, 230]
  if [:o2, :co2, :life_support].map {|v| bits.public_send(v)} == expected
    puts "GOOD"
  else
    puts "Expected to be #{expected.inspect}"
  end
end
