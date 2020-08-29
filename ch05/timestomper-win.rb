#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   timestomp script to mainpulate a file timestamp 
# Requirements:
#   gem install win32-file
# 
require 'win32-file'

def time_stoper(src_file, dst_file)
  File.ctime(dst_file, File.ctime(src_file))
  File.atime(dst_file, File.atime(src_file))
  File.mtime(dst_file, File.mtime(src_file))
end
src_file = 'C:\Windows\System32\calc.exe'
dst_file = 'nc.exe'
time_stoper(src_file, dst_file)
puts "Create: #{File.ctime(dst_file)}"
puts "Access: #{File.atime(dst_file)}"
puts "Modify: #{File.mtime(dst_file)}"
