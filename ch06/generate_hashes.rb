#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Generating all hashes in chapter 6
# Requirements:
#
require 'digest'
require 'openssl'

password = 'BlackHat@Offensive-Ruby'

puts "[+] Cleartext Password:"
puts password

# Generating MD5 Hash
puts "[+] MD5 Hash:"
puts Digest::MD5.hexdigest(password)

# Generating SHA1 Hash
puts "[+] SHA1 Hash:"
puts Digest::SHA1.hexdigest(password)

# Generating SHA2 Hash
puts "[+] SHA2 Hash (SHA256, SHA256, SHA512):"

puts Digest::SHA2.new(bitlen = 256).hexdigest(password) # bitlen could be 256, 384, 512

# Direct
puts Digest::SHA256.hexdigest(password)
puts Digest::SHA384.hexdigest(password)
puts Digest::SHA512.hexdigest(password)

# Linux password hash
puts "[+] SHA2 Hash (Linux password):"
salt = rand(36**8).to_s(36)
puts shadow_hash = password.crypt("$6$" + salt)

if File.exist?('lm_hash.rb')
  # Generating Windows LM Password Hash
  puts "[+] Windows LM Password Hash:"
  puts `ruby lm_hash.rb` 
end 

# Generating Windows NTLM1 Password Hash
puts "[+] Windows NTLM1 Password Hash:"
ntlmv1 = OpenSSL::Digest::MD4.hexdigest(password.encode('UTF-16LE'))
puts ntlmv1

# Generating Windows NTLM2 Password Hash
puts "[+] Windows NTLM2 Password Hash:"
ntlmv1     = OpenSSL::Digest::MD4.hexdigest(password.encode('UTF-16LE'))
userdomain = "administrator".encode('UTF-16LE')
ntlmv2     = OpenSSL::HMAC.digest(OpenSSL::Digest::MD5.new, ntlmv1, userdomain)
puts ntlmv2

# Generating MySQL Password Hash
puts "[+] MySQL Password Hash:"
puts "*" + Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase

# Generating PostgreSQL Password Hash
puts "[+] PostgreSQL Password Hash:"
puts 'md5' + Digest::MD5.hexdigest(password + 'admin')
