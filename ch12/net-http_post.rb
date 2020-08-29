#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   SSSS
# Requirements: 
#   none
# 
require 'net/http'
require 'openssl'

uri  = URI.parse("http://testasp.vulnweb.com/Register.asp")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl     = true if uri.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

headers = {
  'User-Agent'   => 'Black Hat Ruby',
  'Content-Type' => 'application/x-www-form-urlencoded'
 }
req = Net::HTTP::Post.new(uri.request_uri, headers)
req.set_form_data({
  "tfEmail" => "king.sabri@gmail.com",
  "tfUPass" => "MyAwesomePass0rd",
  "tfRName" => "Black Hat Ruby",
  "tfUName" => "BlackHatRuby"
})

res = http.request(req)
puts "[*] Status code:      #{res.code}"
puts "[*] Response Headers: #{res.to_hash}" 
puts "[*] Response body:    #{res.body}"
