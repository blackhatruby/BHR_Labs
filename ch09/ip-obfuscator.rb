#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   IP address operations
# Requirements:
#   gem install async-await
# 
require 'ipaddr'

ipaddr    = "192.168.100.10"
ip_octets = ipaddr.split('.').map(&:to_i)
ip = IPAddr.new(ipaddr)

# to deceimal
puts "[+] IP to Decimal"
puts "http://" + ip.to_i.to_s	                    # http://3232261130

# full hex
puts "\n[+] IP to Hex"

# puts "http://" + ip.to_string.to_s(16)                 # http://0xc0a8640a
puts "http://" + sprintf("0x%02x", ip.to_i)  # http://0xc0a8640a

# hex per octet
puts "\n[+] IP to Hex/octet"
puts "http://" + ip_octets.map {|octet| sprintf("0x%02x", octet)}.join('.') #http://0xc0.0xa8.0x64.0xa
puts "http://" + ip_octets.map {|octet| sprintf("0x%08x", octet)}.join('.') #http://0x00000000c0.0x00000000a8.0x0000000064.0x00000000a

# octal per octet
puts "\n[+] IP to Octal"
puts "http://" + sprintf("0%08o", ip.to_i)   # http://030052062012

puts "\n[+] IP to Octal/octet"
puts "http://" + ip_octets.map {|octet| sprintf("0%o", octet)}.join('.')     # http://0300.0250.0144.012
puts "http://" + ip_octets.map {|octet| sprintf("0%08o", octet)}.join('.')   # http://00000000300.00000000250.00000000144.0000000012

puts "\n[+] IPv4 mapping into IPv6:"
puts "http://" + ip.ipv4_compat.to_string	  # http://0000:0000:0000:0000:0000:0000:c0a8:640a
puts "http://" + ip.ipv4_mapped.to_string	  # http://0000:0000:0000:0000:0000:ffff:c0a8:640a



# https://github.com/jesuGMZ/url-obfuscation

# https://news.ycombinator.com/item?id=14997512
# Decimal Dotted http://192.168.0.1/

# Decimal Dotted Overflow http://448.424.256.257/

# Decimal Long http://3232235521/

# Decimal Long Overflow http://7527202817/

# Decimal Class A http://192.11010049/

# Decimal Class B http://49320.1/

# Decimal Class C http://12625920.1/

# Decimal Long with auth http://fake.site@3232235521/

# Octal Dotted http://0300.0250.00.01/

# Octal Dotted Overflow http://0700.0650.0400.0401/

# Octal Long http://030052000001/

# Octal Long Overflow http://070052000001/

# Octal Class A http://0300.052000001/

# Octal Class B http://0140250.01/

# Octal Class C http://060124000.01/

# Octal Long with auth http://fake.site@030052000001/

# Hex Dotted http://0xc0.0xa8.0x0.0x1/

# Hex Dotted Overflow http://0x1c0.0x1a8.0x100.0x101/

# Hex Long http://0xc0a80001/

# Hex Long Overflow http://0x1c0a80001/

# Hex Class A http://0xc0.0xa80001/

# Hex Class B http://0xc0a8.0x1/

# Hex Class C http://0xc0a800.0x1/

# Hex Long with auth http://fake.site@0xc0a80001/




# [~] Obfuscated IPs:

# [+] http://3232261130     ok
# [+] http://0xc0a8640a	    ok
# [+] http://030052062012  ok

# [+] http://0300.0250.0144.012 ok
# [+] http://00000000300.00000000250.00000000144.0000000012 ok
# [+] http://0xc0.0xa8.0x64.0xa ok
# [+] http://0x00000000c0.0x00000000a8.0x0000000064.0x00000000a ok

# [+] http://0xc0.0xa8.0x64.10
# [+] http://0xc0.0xa8.100.10
# [+] http://0xc0.168.100.10
# [+] http://192.0xa8.0x64.0xa
# [+] http://192.168.0x64.0xa
# [+] http://192.168.100.0xa

# [+] http://0300.0250.0144.10
# [+] http://0300.0250.100.10
# [+] http://0300.168.100.10
# [+] http://192.0250.0144.012
# [+] http://192.168.0144.012
# [+] http://192.168.100.012

# [+] http://0xc0.0xa8.25610
# [+] http://0xc0.11035658
# [+] http://0300.0250.25610
# [+] http://0300.11035658
# [+] http://0xc0.0250.25610
# [+] http://0300.0xa8.25610

# [+] http://::ffff:c0a8640a
# [+] http://0:0:0:0:0:ffff:c0a8640a
# [+] http://0000:0000:0000:0000:0000:ffff:c0a8640a
# [+] http://0000:0000:0000:0000:0000:ffff:192.168.100.10
