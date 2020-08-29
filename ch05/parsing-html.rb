#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Parsing HTML files
#   https://www.rubyguides.com/2012/01/parsing-html-in-ruby/
# Requirements:
#   gem install nokogiri
#
require 'nokogiri'

html = Nokogiri::HTML.parse(open("index.html"))

puts "[+] Title: #{html.title}"
book = html.css('/html/body/ul/span/li').map do |mod|
  mod_name = mod.css('strong').text
  chp_name = mod.css('ul/li/div').map(&:text)
  {mod_name => chp_name}
end
pp book
