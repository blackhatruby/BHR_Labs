#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   TCP client - Socket 
# Requirements:
#
require 'socket'

socket = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(9911, 'localhost')
socket.connect(addr)
socket.close