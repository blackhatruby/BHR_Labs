#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A pure Ruby SSH client that gives you a PTY session on the remote host
# Requirements:
#   gem install net-ssh
#
require 'net/ssh'

hostname = "192.168.108.129"#"192.168.100.17"
username = "root"
password = "123123"

Net::SSH.start(hostname, username, :password => password) do |session|
  session.open_channel do |channel|
    channel.request_pty
    channel.send_channel_request("shell")
    channel.on_data do |_ch, data|
      print data
      cmd = gets
      channel.send_data("#{cmd}")
    end
  end
  session.loop { true }
end
