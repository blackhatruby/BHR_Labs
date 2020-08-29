#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Terminal Cursor manipulation
# Requirements:
#

(1..10).each do |percent|
  print "#{percent*10}% complete\r"
  sleep(0.5)
  print  ("\e[K") # Delete current line
end
puts "Done!"
