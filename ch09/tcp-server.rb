#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A simple greeting TCP server
# Requirements:
#
require 'socket'

server = TCPServer.new('0.0.0.0', 9911)      # Server, binds/listens all interfaces on port 9911

loop do 
  client = server.accept                     # Wait for client to connect
  rhost  = client.peeraddr.last              # peeraddr, returns remote [address_family, port, hostname, numeric_address(ip)]
  client.puts "What's your name, #{rhost}?"  # Send a message to the client once it connect
  name   = client.gets                       # Read incoming message from client
  client.puts "Greeting, #{name}"            # Send a message to the client once it connect
  client.close                               # Close the client's connection
  server.close if name == 'close'            # Close the TCP Server
end
