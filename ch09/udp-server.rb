#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A Simple UDP server
# Requirements:
#
require 'socket'
puts "[+] Starting UDP Server.."

server_ip, server_port = '0.0.0.0', 9911
server = UDPSocket.new                                                  # Start UDP socket
server.bind(server_ip, server_port)                                     # Bind all interfaces to port 9911
                   
loop do
  msg, addr = server.recvfrom(1024)                                     # Receive 1024 bytes of the message and the sender IP details
  puts "Client says:"
  puts msg                                                              # Receive 1024 bytes of the client's message
  client_port = addr[1]
  client_ip   = addr[3]
  server.send("Hi, UDP Client #{client_ip}", 0, client_ip, client_port) # Send a message to the client
end
