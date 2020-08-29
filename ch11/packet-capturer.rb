#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Packet capture for FTP to pcapng file
# Requirements:
#   $ apt install libpcap-dev
#   $ gem install packetgen
# 
require 'packetgen'

pkt = PacketGen.capture(iface: 'wls1', filter: 'port ftp or ftp-data', max: 20)
PacketGen.write('ftp-captured.pcapng', pkt)
