#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   String Generation | Pattern Create and Pattern Offset
# Requirements: 
# 

# Pattern Create
puts "[+] Pattern create"
buffer = 5000 # the pattern legnth we want
pattern_create = ('Aa0'..'Zz9').to_a.join
# pattern_create = ('Aa0'..'Zz9').to_a.join.slice(0, buffer)
# pattern_create = ('Aa0'..'Zz9').to_a.join[0, buffer]
pp pattern_create = pattern_create  * (buffer / 20280.to_f).ceil

# Pattern Offsets
puts "[+] Pattern offset of (0x357A5534)"
pp offset = ['357A5534'].pack("H*").reverse
found = pattern_create.to_enum(:scan, offset).map { Regexp.last_match.begin(0) }
puts "[+] Found the offset (#{offset}) after '#{found[0]}' characters."
