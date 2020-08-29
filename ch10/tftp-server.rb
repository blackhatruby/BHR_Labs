#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri | @KINGSABRI
# Description:
#   Pure Ruby TFTP server
# Requirements:
#   gem install fx-tftp
# 
require 'tmpdir'
tmp_dir = Dir.mktmpdir("bhr-tmp")
puts "[+] Temp Directory: #{tmp_dir}"
`tftpd -a 0.0.0.0 -p 69 #{tmp_dir} -v`
