#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A script the mimic ifconfig linux command to list all network interfaces
# Requirements:
#
require 'socket'


Socket.getifaddrs.map do |iface|
  next unless iface.addr.ipv4?
  puts "Name      : " + iface.name
  puts "IP Address: " + iface.addr.ip_address
end

