#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Forward SSH Tunnel
#   After executing the script on the attacker server, open a new terminal and execute
#   $ rdesktop localhost:2222
# Requirements:
#   gem install net-ssh
# 
require 'net/ssh'

ssh_server           = '192.168.100.17'
ssh_username         = 'root'
ssh_password         = '123123'
internal_server      = '192.168.100.14'
internal_server_port = 3389

Net::SSH.start(ssh_server, ssh_username, :password => ssh_password) do |session|
  session.forward.local('0.0.0.0', 2222, internal_server, internal_server_port)
  puts "[+] Starting SSH forward tunnel"
  session.loop { true }
end
