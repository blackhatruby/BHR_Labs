#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   URL extractor to unshorten shortened URLs
# Requirements: 
#   none
# 
require 'net/http'
uri = ARGV[0]
loop do
  puts uri
  res = Net::HTTP.get_response(URI(uri))
  # !res['location'].nil? ? uri = res['location'] : break
  # res.kind_of?(Net::HTTPRedirection)? uri = res['location'] : break
  res.is_a?(Net::HTTPRedirection)? uri = res['location'] : break
end


