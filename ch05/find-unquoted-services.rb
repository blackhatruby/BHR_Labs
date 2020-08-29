#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Find all services that are vulnerable with "Unquoted Service Path"
#   - you can install "Abyss Web Server X1 2.11.1.exe" to practice on it
# Requirements:
#   Windows OS
#
require 'win32ole'
wmi = WIN32OLE.connect("winmgmts://")
ps = wmi.ExecQuery("Select * from Win32_Service where StartMode = 'Auto'")

vuln_services = ps.each.select do |s| 
    path = s.pathname.match(/.*\.exe/).to_s
    path.include?(' ') && 
    !(path.start_with?('"') && path.end_with?('"')) &&
    File.writable?(path)
end

puts "[+] Vulnerable services found: #{vuln_services.size}"
puts vuln_services.map(&:pathname)
