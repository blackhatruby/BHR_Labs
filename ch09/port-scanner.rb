#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   High performance port scanner
# Requirements:
#   gem install async-io async-await
# 
require 'async/io'
require 'async/await'
require 'async/semaphore'

class PortScanner
  include Async::Await

  def initialize(host: '0.0.0.0', ports:, batch_size: 1024)
    @host      = host
    @ports     = ports
    @semaphore = Async::Semaphore.new(batch_size)
  end

  def scan_port(port, timeout)
    with_timeout(timeout) do
      address = Async::IO::Address.tcp(@host, port)
      peer = Async::IO::Socket.connect(address)
      puts "#{port} open"
      peer.close
    end
  rescue Errno::ECONNREFUSED
    puts "#{port} closed"
  rescue Async::TimeoutError
    puts "#{port} timeout"
  end

  async def start(timeout = 1.0)
    @ports.map do |port|
      @semaphore.async do
        scan_port(port, timeout)
      end
    end.collect(&:result)
  end
end

host = ARGV[0]
if host.nil? || host.empty?
  puts "Usage:\n  ruby port-scanner.rb <IP ADDRESS>"
  exit!
end

limits = Process.getrlimit(Process::RLIMIT_NOFILE)
batch_size = [512, (limits.first * 0.9).ceil].min
scanner = PortScanner.new(host: host, ports: Range.new(1, 65535), batch_size: batch_size)

scanner.start