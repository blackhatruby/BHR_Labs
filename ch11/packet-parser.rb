#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Packet parser for pcapng file
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
require 'packetgen'

pkts = PacketGen.read(ARGV[0])
pkts.each do |pkt| 
  if pkt.tcp.body.include?("USER") || pkt.tcp.body.include?("PASS")
    puts pkt.ip.src + " -> " + pkt.ip.dst 
    puts pkt.tcp.body
  end
end