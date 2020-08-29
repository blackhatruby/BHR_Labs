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
#

def time_stoper(src_file, dst_file)
  File.utime(File.atime(src_file), File.ctime(src_file), dst_file)
end

src_file, dst_file = ARGV 

time_stoper(src_file, dst_file)