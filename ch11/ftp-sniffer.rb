#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Packet Sniffer for FTP 
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
require 'packetgen'

PacketGen.capture(iface: 'wls1', filter: 'port ftp or ftp-data', max: 1000) do |pkt|
  # pp pkt
  if pkt.tcp.body.include?("USER") || pkt.tcp.body.include?("PASS")
    puts pkt.ip.src + " -> " + pkt.ip.dst 
    puts pkt.tcp.body
  end
end
