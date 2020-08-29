#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A simple script to encrypt and decrypt a string using RSA encryption
#   Notes:
#     - You should save public and private keys on disk to use later
#     - Public key is to be shared with people
#     - Private key should be encrypted (as we did) and stored securely
# Requirements:
#
require 'openssl'

data = 'Black Hat Ruby Secret!'

rsa = OpenSSL::PKey::RSA.new(2048)
pub_key = rsa.public_key
cipher = OpenSSL::Cipher::AES256.new(:CBC)
prv_key = rsa.export(cipher, 'BlackHat@Offensive-Ruby') # Use RSA with 'BlackHat@Offensive-Ruby' password to encrypt the private key 

puts "[+] Public key"
pp pub_key
puts "\n[+] Private key (AES256(CBC) encrypted with password: BlackHat@Offensive-Ruby )"
pp prv_key

puts "\n[+] Encrypted string"
encrypted_string = pub_key.public_encrypt(data)
pp encrypted_string

puts "\n[+] Decrypted string"
decrypted_string = rsa.private_decrypt(encrypted_string)
pp decrypted_string