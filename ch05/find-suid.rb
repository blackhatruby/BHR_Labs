#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Finding executable files with SUID flag on Linux
# Requirements:
#
require 'find'

# ruby -r find -e "files = [] ; Find.find('/') {|file| files << file if (File.file?(file) && File.stat(file).setuid? && File.executable?(file)) rescue next}; puts files"

# def find_suid(path)
#   files = []
#   Find.find(path) do |file|
#     if (File.file?(file) && File.stat(file).setuid? && File.executable?(file)) rescue next
#       files << file
#     end
#   end
#   files
# end

# puts find_suid('/')


require 'find'

def find_suid(path)
  files = []
  Find.find(path) do |f|
    if (File.file?(f) && File.stat(f).setuid? && File.executable?(f))
      files << f
    end
  rescue 
    next
  end
  files
end
puts find_suid('/')
