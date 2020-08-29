#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Windows LM Password Hash
#     1. Convert all lower case to upper case
#     2. Pad password to 14 characters with NULL characters
#     3. Split the password into two 7-characters chunks
#     4. Create two DES keys from each 7-characters chunk
#     5. DES encrypt the string "KGS!@#$%" with these two chunks
#     6. Finally, Concatenate the two DES encrypted strings.
# Requirements:
#
require 'openssl'

def split7(str)
  str.scan(/.{1,7}/)
end

def gen_keys(str)
  split7(str).map do |str7| 
    bits = split7(str7.unpack("B*")[0]).inject('') do |ret, tkn| 
      ret += tkn + (tkn.gsub('1', '').size % 2).to_s 
    end
    [bits].pack("B*")
  end
end

def apply_des(plain, keys)
  des = OpenSSL::Cipher::DES.new
  keys.map do |key|
    des.key = key
    des.encrypt.update(plain)
  end
end

def lm_hash(password)
  lm_magic = "KGS!@\#$%"
  keys     = gen_keys(password.upcase[0,13].ljust(14, "\0"))
  apply_des(lm_magic, keys).join
end

pp lm_hash "BlackHat@Offensive-Ruby"
