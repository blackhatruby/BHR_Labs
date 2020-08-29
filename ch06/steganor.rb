#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Simple script to hide a file in another file then writes it into third one.
# Requirements:
#
file1, file2, file3 = ARGV
file3 = file3 || "steg.png"

if (file1 || file2).nil? || (file1 || file2).empty?
  puts "Usage:\n  ruby steganor.rb <image.png> <file.pdf> [output.png]"
  exit!
end

orig_file = File.read(file1)
sec_file  = File.read(file2)
separator = "*------------[#{file2}]------------*"
output    = [orig_file, separator, sec_file]

File.open(file3, 'wb') do |stg|
  output.each do |f|
    stg.puts f
  end
end
puts "[+] Generated output: #{file3}"