#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A simple SSH client to execute command on a remote host
# Requirements:
#   gem install net-ssh
# 
require 'net/ssh'

hostname = "192.168.108.129"
username = "root"
password = "123123"

begin
  ssh = Net::SSH.start(hostname, username, :password => password, non_interactive: true)
  res = ssh.exec!("ifconfig -a")
  ssh.close
  puts res
rescue Exception => e
  puts "Unable to connect to #{hostname} using #{username}/#{password}"
  puts e
end
