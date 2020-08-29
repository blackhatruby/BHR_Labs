#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   HTTP Basic Authentication
# Requirements: 
#   none
# 
require 'net/http'

username = "Admin"
password = "BlackHat@Offensive-Ruby"

uri  = URI("http://blackhatruby.com/login")
http = Net::HTTP.new(uri.host, uri.port)
req  = Net::HTTP::Get.new(uri)
req.basic_auth(username, password)
res  = http.request(req)

puts res.body