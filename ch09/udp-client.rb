#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   UDP Client
# Requirements:
#
require 'socket'

puts "[+] Starting UDP Client.."
client = UDPSocket.new
# client.connect('localhost', 9911)     # Connect to server on port 9911
client.connect('192.168.100.10', 9911)  # Connect to server on port 9911
client.puts("Hi, UDP Server!", 0)       # Send message 
puts "Server says:"
puts client.recv(1024)                  # Receive 1024 bytes of the server message
