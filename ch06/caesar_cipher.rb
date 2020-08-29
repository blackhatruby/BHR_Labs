#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Caesar cipher
# Requirements:
#

def caesar_cipher(string, shift=1)
  lowercase, uppercase = ('a'..'z').to_a, ('A'..'Z').to_a
  lower = lowercase.zip(lowercase.rotate(shift)).to_h
  upper = uppercase.zip(uppercase.rotate(shift)).to_h

  # One-liner: encrypter = ([*('a'..'z')].zip([*('a'..'z')].rotate(shift)) + [*('A'..'Z')].zip([*('A'..'Z')].rotate(shift))).to_h
  encrypter = lower.merge(upper)
  string.chars.map{|c| encrypter.fetch(c, c)}
end

string = ARGV[0]
if string.nil? || string.empty?
  puts "Usage:\n  ruby caesar_cipher.rb <SECRET>"
  exit!
end
1.upto(30) do |r|
  puts "ROT#{r}) " + caesar_cipher(string, r).join
end
