#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   accessing a post authenticated page
# Requirements: 
#   none
# 
require 'net/http'

uri  = URI.parse("http://blackhatruby.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true if uri.scheme == 'https'

puts "[*] Logging in"
auth_req = Net::HTTP::Post.new('/login.php')
auth_req.set_form_data({"username"=>"admin", "password"=>"BlackHat@Offensive-Ruby"})
auth_res = http.request(auth_req)
cookies  = auth_res.response['set-cookie']    # Save Cookies

puts "[*] Do Post-authentication actions"
req  = Net::HTTP::Get.new('/admin/users.php')
req['Cookie'] = cookies 
res  = http.request(req)

