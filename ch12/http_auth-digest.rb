#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   HTTP Digest Authentication
# Requirements: 
#   gem install net-http-digest_auth
# 
require 'net/http'
require 'net/http/digest_auth'

uri          = URI("http://blackhatruby.com/login")
uri.user     = "Admin"
uri.password = "BlackHat@Offensive-Ruby"

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true if uri.scheme == 'https'

req_init = Net::HTTP::Get.new(uri.request_uri)
res_init = http.request(req_init)

digest_auth = Net::HTTP::DigestAuth.new
auth = digest_auth.auth_header(uri, res_init['www-authenticate'], 'GET')
req  = Net::HTTP::Get.new(uri.request_uri)
req.add_field('Authorization', auth)
res  = http.request(req)

puts res.body
