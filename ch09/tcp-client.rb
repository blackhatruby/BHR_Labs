#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A simple TCP client for TCP greeting server
# Requirements:
#
require 'socket'

# socket = TCPSocket.open('localhost', 9911)
# pp socket.recv(1024)
# socket.send("Sabri\r\n", 0)
# pp socket.recv(1024)
# socket.close


TCPSocket.open('localhost', 9911) do |s|
  pp s.recv(1024)
  s.send("Sabri\r\n", 0)
  pp s.recv(1024)
  s.close  
end

