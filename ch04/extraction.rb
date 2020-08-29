#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   String Extraction
# Requirements: 
#   

# MAC address
mac = "Lorem Ipsum is simply3c:77:e6:68:66:e9dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text 1100:50:7F:E6:96:20ever since the 15:00s, when an unknown printer took a galley of type and00:50:56:c0:00:08scrambled it to make a type specimen00-0C-29-38-1D-61 00:11:22book.FF:DD:CC"
mac_regex = /(?:[0-9A-F][0-9A-F][:\-]){5}[0-9A-F][0-9A-F]/i
mac.scan(mac_regex)

puts "-----"

# IPv4 address 
ip = "Lorem Ipsum is simply dummy text of192.168.100.10 the printing and typesetting industry. Lorem Ipsum has been172.16.16.185 the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type8.8.8.8and scrambled it 20.555.1.700 to make a type specimen book."
ipv4_regex = /(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
ip.scan(ipv4_regex)

puts "-----"

# URLs
urls = "Lorem Ipsum is simplyhttp://sabrisaleh.info dummy text of the printing https://king-sabri.netand typesetting industry. Lorem https://rubyfu.net Ipsum has been the industry's standard dummy text ever since the https://nostarch.com/ 1500s, when an unknown printer took a galley of type and scrambled  it to make a type specimen book."
urls.scan(/https?:\/\/[\S]+/)
require 'uri'
URI.extract(urls, ["http", "https"])

puts "-----"

# Email Address
emails = "is simply dummy text of the printing and user1@exmaple.com typesetting industry. Lorem Ipsum has user1@marketing.exmaple2.com been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and wrong@@email.ext scrambled it to make a type specimen book."
email_regex = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
emails.scan(email_regex)

puts "-----"

# HTML
html = <<~HTMLDOC
<html>
<head>
<title>Offensive Ruby</title>
</head>
<body>
​
<h1>This is a Heading</h1>
<p>This is another <strong>content</strong>.</p>
​
</body>
</html>
HTMLDOC
puts html.gsub(/<.*?>/,'').strip.squeeze
