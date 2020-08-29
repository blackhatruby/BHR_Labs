#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Pure Ruby FTP server
# Requirements:
#   gem install ftpd
# 
require 'tmpdir'

tmp_dir = Dir.mktmpdir("bhr-tmp")
puts "[+] Temp Directory: #{tmp_dir}"
`ftpdrb -i 0.0.0.0 -p 21 -U ftp -P ftp@123 --path #{tmp_dir}`
