
#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Rijndael AES-128 bit encryptor 
# Requirements:
#
require 'openssl'
require 'base64'

cleartext = 'BlackHatRuby Secret Mission: Go Hack The World!'
key = '17cd9e11b9d4909247a8707b7659b6a5'
iv  = '185c155d0ad655c6bf40e1c9e1a2a403'

cipher = OpenSSL::Cipher.new("AES-128-CBC")
cipher.encrypt
cipher.padding = 0
cipher.key = cipher.random_key #[key].pack('H*')
cipher.iv  = cipher.random_iv  #[iv].pack('H*')
encrypted  = cipher.update(cleartext + "A" * (16 - cleartext.size % 16)) + cipher.final
puts encrypted.unpack('H*').first.upcase

