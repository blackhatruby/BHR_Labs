#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Pure Ruby SSH Server
# Requirements:
#   gem install hrr_rb_ssh
#   Unix based platform
# 
require 'hrr_rb_ssh'

include HrrRbSsh

auth_password = Authentication::Authenticator.new do |context|
  username = ENV['USER']
  password = '123123'
  context.verify username, password
end

options = {}
options['authentication_password_authenticator']    = auth_password
options['connection_channel_request_pty_req']       = Connection::RequestHandler::ReferencePtyReqRequestHandler.new
options['connection_channel_request_env']           = Connection::RequestHandler::ReferenceEnvRequestHandler.new
options['connection_channel_request_shell']         = Connection::RequestHandler::ReferenceShellRequestHandler.new
options['connection_channel_request_exec']          = Connection::RequestHandler::ReferenceExecRequestHandler.new
options['connection_channel_request_window_change'] = Connection::RequestHandler::ReferenceWindowChangeRequestHandler.new

port   = 2222
server = TCPServer.new(port)
puts "[+] Starting SSH server on port #{port}"
loop do
  Thread.new(server.accept) do |io|
    pid = fork do
      begin
        ssh_server = HrrRbSsh::Server.new(options)
        ssh_server.start(io)
      ensure
        io.close
      end
    end
    io.close
    Process.waitpid(pid)
  end
end
