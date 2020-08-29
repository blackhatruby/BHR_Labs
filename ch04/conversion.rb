#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   String Conversion
# Requirements: 
#   

# Converting string to hex
str = 'Black Hat Ruby'
pp str.unpack("H*")

puts "-----"

# Metho 1 | Unpack
pp str.unpack('C*').map { |b| '\x%02x' % b }.join

puts "-----"

# Method 2 | each_byte()
pp str.each_byte.map { |b| '\x%02x' % b }.join

puts "-----"

# Method 3 | to_s()
pp str.each_byte.map { |b| '\x' + b.to_s(16).rjust(2, '0') }.join

puts "-----"

# Case study | Raw data in the wire
ip = "192.168.100.10"
pp ip.each_byte.map { |c| sprintf('\x%02x', c) }.join
pp ip.split('.').map(&:to_i).pack("C*") # expected

puts "-----"

# Convert hex to string
puts "\x42\x6c\x61\x63\x6b\x20\x48\x61\x74\x20\x52\x75\x62\x79"
pp ["426c61636b204861742052756279"].pack('H*')

puts "-----"

# Return address (Lettle-Endian )
pp "\x77\xd6\xb1\x41"         # 0x77d6b141
pp "\x41\xb1\xd6\x77"         # Manual reverse (returns the correct value)
pp "\x77\xd6\xb1\x41".reverse # Using String#reverse method (returns the incorrect value)
pp [0x77d6b141].pack('V')     # (returns the correct value)
pp [0x77d6b141].pack('V').force_encoding("UTF-8")

puts "-----"

# Base64
[str].pack('m0')
require 'base64'
pp Base64.encode64(str)
pp "T2ZmZW5zaXZlIFJ1Ynk=".unpack('m0')
pp Base64.strict_encode64(str.encode('UTF-16LE')) # Windows compatible 

