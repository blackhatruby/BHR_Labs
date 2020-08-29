#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Terminal cursor manipulation 
# Requirements: 
#   

(1..3).map do |num|
  print "\rNumber: #{num}"
  sleep 0.5
  print ("\033[1B")    # Move cursor down 1 line 

  ('a'..'c').map do |char|
    print "\rCharacter: #{char}"
    # print  ("\e[K")
    sleep 0.5
    print ("\033[1B")    # Move cursor down 1 lines

    ('A'..'C').map do |char1|
      print "\rCapital: #{char1}"
      # print  ("\e[K")
      sleep 0.3
    end
    print ("\033[1A")    # Move curse up 1 line

  end

  print ("\033[1A")    # Move curse up 1 line
end

print ("\033[2B")    # Move cursor down 2 lines
puts ""


(1..10).each do |percent|
  print "#{percent*10}% complete\r"
  sleep(0.5)
  print  ("\e[K") # Delete current line
end
puts "Done!"


(1..5).to_a.reverse.each do |c|
  print "\rI'll exit after #{c} second(s)"
  print "\e[K"
  sleep 1
end
puts 
