#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Script to convert a UTF-16 encoded file to UTF-8 encoding
# Requirements: 
#   gem install iconv
# 
require 'iconv'
file   = ARGV[0]
string = open(file).read.scrub
converted = Iconv.conv('UTF-8', 'UTF-16', string).scrub
File.write("utf8-#{file}", converted)
