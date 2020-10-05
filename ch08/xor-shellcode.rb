#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Encrypt shellcode binary file using XOR technique.
#   Give the binary shellcode as a file to the script. 
#   The script will generate an array in C format of the encrypted shellcode
# Requirements:
# 
def xor(data, key)
  data.bytes.map.with_index do |byte, i|
    current_key = key[i % key.size]
	 (current_key.ord ^ byte).to_s(16)
  end
end

def print_c_format(ciphertext)
  '{ 0x' + ciphertext.join(', 0x') + ' };'
end

begin
  plaintext = open(ARGV[0], "rb").read
rescue Exception => e 
   puts e.message 
   puts "File argument needed!"
   exit!
end 

key = "BlackHatRuby"
ciphertext = xor(plaintext, key)
puts print_c_format(ciphertext)
