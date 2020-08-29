#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   TCP Server - Socket 
# Requirements:
#
require 'socket'

addr   = Socket.pack_sockaddr_in(9911, '0.0.0.0') # Packs port and host as an AF_INET/AF_INET6 sockaddr string
server = Socket.new(:INET, :STREAM)               # Create Socket
server.bind(addr)                                 # Bind to a port and address
# server.listen(Socket::SOMAXCONN)                # Listen to number of connections
server.listen(3)                                  # Listen to number of connections
conn   = server.accept                            # Accept incoming connection
server.close