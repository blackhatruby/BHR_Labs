#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Ground up HTTP GET request 
# Requirements: 
#   none
# 
require 'net/http'
require 'openssl'

proxy_addr = 'localhost'
proxy_port = 8080
proxy_user = nil
proxy_pass = nil 

uri  = URI.parse('https://www.google.com.sa/search?q=Black Hat Ruby')
http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port, proxy_user, proxy_pass)

http.use_ssl     = true if uri.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE 

req  = Net::HTTP::Get.new(uri.request_uri)
pp req.to_hash
req["User-Agent"] = "Black Hat Ruby"

res  = http.request(req)
res.code
res.message
res.code_type
res.content_type
pp res.to_hash
pp res.body



# Net::HTTP.get_response(URI('https://www.google.com.sa/search?q=Black Hat Ruby'))
