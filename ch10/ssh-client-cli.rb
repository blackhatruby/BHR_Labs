#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A pure Ruby SSH client that gives you a PTY interactive session on the remote host
# Requirements:
#   gem install net-ssh
#   gem install net-ssh-cli
#
require 'net/ssh/cli'
require 'readline'
hostname = "192.168.100.104"
username = "root"
password = "123123"

prompt = /#{username}.*/m
Net::SSH.start(hostname, username, password: password) do |ssh|
  cli = ssh.cli(default_prompt: prompt)
  print cli.cmd "" # SSH Server Banner
  loop { print cli.cmd Readline.readline }
end

