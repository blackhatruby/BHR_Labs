#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   String Detecting Terminal Size
# Requirements: 
# 

# Method #1 : By IO/console standard library
require 'io/console'
rows, columns = $stdin.winsize
# Try this now
print "-" * (columns/2) + "\n" + ("|" + " " * (columns/2 -2) + "|\n")* (rows / 2) + "-" * (columns/2) + "\n"


# Method #2: By readline standard library
require 'readline'
  Readline.get_screen_size


# Method #3: By environment like IRB or Pry
[ENV['LINES'].to_i, ENV['COLUMNS'].to_i]


# Method #4  By tput command line
[`tput cols`.to_i , `tput lines`.to_i]