#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Parsing XML files
# Requirements:
#   gem install SSSS
#
require 'nokogiri'

xml = Nokogiri::XML.parse(open("index.xml"))
puts "[+] Title: " + xml.search("//title").text
book = xml.search("//orderedlist/listitem/module").map do |mod|
  mod_id_attr   = mod.get_attribute('id')
  mod_name_attr = mod.get_attribute('name')
  mod_name      = "Module #{mod_id_attr} | #{mod_name_attr}"
  mod_chps = mod.elements.map do |ch|
    "Chapter #{ch.get_attribute('id')} – #{ch.get_attribute('name')}"
  end
  {mod_name => mod_chps}
end
pp book

