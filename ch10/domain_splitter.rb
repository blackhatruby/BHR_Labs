#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Simple script to split data to subdomain compliant
# Requirements:
#
require 'securerandom'

domain = ARGV[0] || "attacker.zone"
data   = ARGV[1] || SecureRandom.alphanumeric(250 - domain.size)

puts "\n\n"
# data.chars
#     .each_slice(250 - domain.size)
#     .each_slice(65)
#     .each_slice(3)
#     .map do |sub|
#       puts sub.map(&:join).join('.') + domain
#       puts "---"
#     end


# pp subdomain.chars.each_slice(65).each_slice(3).to_a[0]

pp data.chars
    .each_slice(data.size - domain.size).to_a
    .each_slice(65).to_a
    .each_slice(3).to_a
    # .map do |sub|
    #   puts sub.map(&:join).join('.') + domain
    #   puts "---"
    # end

