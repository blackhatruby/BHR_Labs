#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Script to parse command-line arguments with switches.
# Requirements: 
# 

require 'optparse'

options = {}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] [subcommand [options]]"
  opts.on('-t', '--target HOST', 'The target hostname or IP address.') do |v|
    options[:target] = v
  end
  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit!
  end
  opts.on_tail "Examples:"
  opts.on_tail "  #{__FILE__} --target blackhatruby.com"
end

opts.order!
puts "The target is: #{options[:target]}" if options[:target]