#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Pure Ruby TFTP client
# Requirements:
#   gem install rex
# 
require 'rex/proto/tftp/client'
require 'rex/thread_factory'
require 'rex/compat'
require 'rex/file'
require 'optparse'

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def dark_green; colorize(self, "\e[32m"); end
  def blue; colorize(self, "\e[1m\e[34m"); end
  def colorize(text, color_code) "#{color_code}#{text}\e[0m" end
end

def print_status(msg);  puts "[*] ".blue + "#{msg}"; end
def print_good(msg);    puts "[+] ".green + "#{msg}"; end
def print_error(msg);   puts "[x] ".red + "#{msg}"; end
def print_tftp_status(msg)
  case msg
  when /Aborting/, /errors.$/
    print_error msg
  when /^WRQ accepted/, /^Sending/, /complete!$/
    print_good msg
  else
    print_status msg
  end
end

@options = {
  rhost:  nil,
  rport:  69,
  lport:  (1025 + rand(0xffff-1025)),
  lhost:  "0.0.0.0",
  action: 'upload',
  mode:   'octet',
  local_file:  nil,
  remote_file: nil,
}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.on("-i", "--ip IP_ADDR", "The remote TFTP server.") {|v| @options[:rhost] = v}
  opts.on("-p", "--port NUM", "The target port. (default: #{@options[:rport]})", Integer) {|v| @options[:rport] = v}
  opts.on("-l", "--local-file LFILE", "The local filename.") {|v| @options[:local_file] = v}
  opts.on("-r", "--remote-file RFILE", "The remote filename.") {|v| @options[:remote_file] = v}
  opts.on("-a", "--action ACTION", "Action to perform. (default: #{@options[:action]})", 
  "  upload  : Upload FILENAME as REMOTE_FILENAME to the server.",
  "  download: Download REMOTE_FILENAME as FILENAME from the server.") {|v| @options[:action] = v}
  opts.on("-m", "--mode MODE", "The TFTP mode (netascii/octet). (default: #{@options[:mode]})")  {|v| @options[:mode] = v}
  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit!
  end
  opts.on_tail "Examples:"
  opts.on_tail "  #{__FILE__} -i 192.168.100.10 -p 69 -a download -l config.txt -m octet"
  opts.on_tail "  #{__FILE__} -i 192.168.100.10 -p 69 -a upload -r secret.txt -m octet"
end
opts.parse!(ARGV)


def setup
  @lport  = @options[:lport]
  @lhost  = @options[:lhost]
  @rport  = @options[:rport]
  @rhost  = @options[:rhost]
  @action = @options[:action].to_s.downcase.intern
  @mode   = @options[:mode]
  @local_file  = @options[:local_file]
  @remote_file = @options[:remote_file]
end

def set_local_file
  if @local_file
    @local_file
  else
    @local_file = @remote_file
  end
end

def set_remote_file
  if @remote_file
    @remote_file
  else
    @remote_file = File.split(@local_file).last if @local_file
  end
end

def run_upload
  set_local_file
  print_status "Sending '#{@local_file}' to #{@rhost}:#{@rport} as '#{@remote_file}'"
  data = "DATA:#{File.read(@local_file)}"
  tftp_client = Rex::Proto::TFTP::Client.new(
    "LocalHost"  => @lhost,
    "LocalPort"  => @lport,
    "PeerHost"   => @rhost,
    "PeerPort"   => @rport,
    "LocalFile"  => data,
    "RemoteFile" => @remote_file,
    "Mode"       => @mode,
    "Action"     => @action
  )
  tftp_client.send_write_request { |msg| print_tftp_status(msg) }

  while not tftp_client.complete
    select(nil, nil, nil, 1)
    tftp_client.stop
  end
end

def run_download
  set_remote_file
  print_status "Receiving '#{@remote_file}' from #{@rhost}:#{@rport} as '#{@local_file}'"
  tftp_client = Rex::Proto::TFTP::Client.new(
    "LocalHost"  => @lhost,
    "LocalPort"  => @lport,
    "PeerHost"   => @rhost,
    "PeerPort"   => @rport,
    "LocalFile"  => @local_file,
    "RemoteFile" => @remote_file,
    "Mode"       => @mode,
    "Action"     => @action
  )
  tftp_client.send_read_request { |msg| print_tftp_status(msg) }
  
  print_status "Saving #{@remote_file} as '#{@local_file}'"
  until tftp_client.complete
    fh = tftp_client.recv_tempfile
    data = File.open(fh,"rb") {|f| f.read} rescue nil
    File.open(@local_file, 'w') {|f| f.print data}
  end
  tftp_client.stop
ensure
  fh.unlink rescue nil # Windows often complains about unlinking tempfiles
end

def run
  setup
  case
  # ruby tftp-client.rb -i 127.0.0.1 -p 69 -a upload -l secret.txt -r secret.txt
  when @action == :upload
    if @local_file
      run_upload 
      print_good "TFTP transfer operation complete."
    else
      print_error "Need at least a local file name to upload." 
    end
  # ruby tftp-client.rb -i 127.0.0.1 -p 69 -a download -r config.txt -l config.txt
  when @action == :download
    if @remote_file
      run_download
      print_good "TFTP transfer operation complete."
    else
      print_error "Need at least a remote file name to download."
    end
  else
    print_error "Unknown action: '#{@action}'"
  end
end

run
