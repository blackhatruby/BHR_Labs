#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   DNS client operations   
# Requirements:
#   gem install dnsruby
# 
require 'dnsruby'

puts "[+] Query All DNS Records"
resolver = Dnsruby::Resolver.new
resolver.nameservers = ['8.8.8.8', '8.8.4.4']
query = resolver.query("blackhatruby.com", 'ANY', 'IN')
answer = query.answer
puts answer


puts "\n[+] Query Zone Transfer"
zt = Dnsruby::ZoneTransfer.new
zt.server = "nsztm1.digi.ninja"
transfer  = zt.transfer("zonetransfer.me")
puts transfer

puts "\n[+] DNS Trace"
resolver = Dnsruby::Recursor.new
resolver.recursion_callback = Proc.new do |packet|
  packet.additional.each { |a| puts a }
  puts(";; Received #{packet.answersize} bytes from #{packet.answerfrom}. Security Level = #{packet.security_level.string}\n")
  puts "\n#{'-' * 79}\n"
end
response = resolver.query("blackhatruby.com", 'A')
puts response


