#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Pure Ruby TFTP client - simplified version
# Requirements:
#   gem install rex
# 
require 'rex/proto/tftp/client'
require 'rex/thread_factory'
require 'rex/compat'
require 'rex/file'

def upload
  opts = {
    rhost:  '192.168.100.10',
    rport:  69,
    lhost:  "0.0.0.0",
    lport:  (1025 + rand(0xffff-1025)),
    action: :upload,
    mode:   'octet',
    lfile:  'secret.txt',
    rfile:  'secret.txt',
  }

  puts "[*] Uploading '#{opts[:lfile]}' to #{opts[:rhost]}:#{opts[:rport]} as '#{opts[:rfile]}'"
  data = "DATA:#{File.read(opts[:lfile])}"
  tftp_client = Rex::Proto::TFTP::Client.new(
    "LocalHost"  => opts[:lhost],
    "LocalPort"  => opts[:lport],
    "PeerHost"   => opts[:rhost],
    "PeerPort"   => opts[:rport],
    "LocalFile"  => data,
    "RemoteFile" => opts[:rfile],
    "Mode"       => opts[:mode],
    "Action"     => opts[:action]
  )
  tftp_client.send_write_request { |msg| puts "[*] #{msg}" }

  while not tftp_client.complete
    select(nil, nil, nil, 1)
    tftp_client.stop
  end
  puts "[+] TFTP transfer operation complete."
end

def download
  opts = {
    rhost:  '192.168.100.10',
    rport:  69,
    lhost:  "0.0.0.0",
    lport:  (1025 + rand(0xffff-1025)),
    action: :download,
    mode:   'octet',
    lfile:  'config.txt',
    rfile:  'config.txt',
  }
  puts "[*] Downloading '#{opts[:rfile]}' from #{opts[:rhost]}:#{opts[:rport]} as '#{opts[:lfile]}'"
  tftp_client = Rex::Proto::TFTP::Client.new(
    "LocalHost"  => opts[:lhost],
    "LocalPort"  => opts[:lport],
    "PeerHost"   => opts[:rhost],
    "PeerPort"   => opts[:rport],
    "LocalFile"  => opts[:lfile],
    "RemoteFile" => opts[:rfile],
    "Mode"       => opts[:mode],
    "Action"     => opts[:action]
  )
  tftp_client.send_read_request { |msg| puts "[*] #{msg}" }

  puts "[*] Saving #{opts[:rfile]} as '#{opts[:lfile]}'"
  until tftp_client.complete
    fh = tftp_client.recv_tempfile
    data = File.open(fh,"rb") {|f| f.read} rescue nil
    File.open(opts[:lfile], 'w') {|f| f.print data}
  end
  tftp_client.stop
  puts "[+] TFTP transfer operation complete."
ensure
  fh.unlink rescue nil # Windows often complains about unlinking tempfiles
end

download
puts "---"
# upload