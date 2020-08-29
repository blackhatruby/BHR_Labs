#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   AES Encryptor
# Requirements:
#
require "openssl"

data = 'BlackHatRuby Secret Mission: Go Hack The World!'

# Encryption
cipher = OpenSSL::Cipher::AES.new('256-CBC')    # Or use: OpenSSL::Cipher.new('AES-256-CBC')
cipher.encrypt                                  # Initializes the Cipher for encryption. (Must be called before key, iv, random_key, random_iv)
key = cipher.random_key                         # If hard coded key, it must be 265-bits length
iv  = cipher.random_iv                          # Generate iv
encrypted = cipher.update(data) + cipher.final  # Finalize the encryption
puts "[+] Encrypted Data: #{encrypted}"

# Decryption
decipher = OpenSSL::Cipher::AES.new('256-CBC')  # Or use: OpenSSL::Cipher::Cipher.new('AES-256-CBC')
decipher.decrypt                                # Initializes the Cipher for dencryption. (Must be called before key, iv, random_key, random_iv)
decipher.key = key                              # Or generate secure random key: cipher.random_key
decipher.iv  = iv                               # Generate iv
plain = decipher.update(encrypted) + decipher.final  # Finalize the dencryption
puts "[+] Decrypted Data: #{plain}"
