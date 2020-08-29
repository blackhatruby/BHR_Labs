#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Bindary hexdump
# Requirements:
#
def hexdump(file, width = 16, padding = '.')
  ascii = ''
  lnum  = 0

  File.open(file).each_byte.each_slice(width) do |bytes|
    print '%06x  ' % lnum	                      # column 1 | line number
    bytes.map do |byte|
      print '%02x ' % byte	                    # column 2 | hexdump
      ascii << (byte.between?(32, 126)? byte : padding)
      lnum += 1
    end
    puts '   ' * (width - ascii.length) + ascii # column 3 | printable string
    ascii.clear
  end
end

if ARGV.empty?
  puts "Usage:\n ruby #{$0} <FILE>"
else
  filename = ARGV[0]
  hexdump(filename)
end
