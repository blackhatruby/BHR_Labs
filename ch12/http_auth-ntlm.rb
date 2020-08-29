#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   HTTP NTLM Authentication
# Requirements: 
#   gem install ruby-ntlm
# 
require 'ntlm/http'

username = 'administrator'
domain   = 'vulnerable.com'
password = 'BlackHat@Offensive-Ruby'

uri  = URI('http://blackhatruby.com')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true if uri.scheme == 'https'
req  = Net::HTTP::Get.new('/')
req.ntlm_auth(username, domain, password)
res  = http.request(req)
puts res.body





