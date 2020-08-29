#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Mutiple ways to execute system commands
# Requirements:
#

puts "[+] Using system()"
pp system('whoami')

puts "\n[+] Using %x{} and backticks"
pp %x{whoami}
pp `whoami`

puts "\n[+] Using exec()"
fork {pp exec('whoami')} # fork will create a new separated process to execute the method so we can execute the next line
pp exec('whoami')
puts "The script will exit after above line and this line will never get executed"

  