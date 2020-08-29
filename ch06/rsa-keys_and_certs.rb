#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   This script is to generate/create the following for RSA:
#     – Public and Private Key                 : pub.key & prv.key
#     – RSA private key                        : prv.pem
#     – Certificate in PEM format:             : cert.pem
#     – Certificate in encoded DER format      : cert_encoded.der
#     – Certificate in CER format              : cert.cer
#     – Certificate in PFX format              : cert.p12
#     – Self-Signed Digital Certificate (X.509): cert.p12
# Requirements:
#
require 'openssl'
require 'base64'
require 'fileutils'

dir = 'certs'
if Dir.exist?(dir)
  FileUtils.rm_rf(dir)
  Dir.mkdir(dir)
else
  Dir.mkdir(dir)
end

rsa = OpenSSL::PKey::RSA.new(2048)

puts "[+] RSA Public Key: ./#{dir}/pub.key"
File.write("./#{dir}/pub.key", rsa.public_key)

puts "[+] RSA Private Key (cleartext): #{dir}/priv.key"
File.write("./#{dir}/prv.key", rsa)

puts "[+] Self-Signed Certificate:"
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial  = Random.rand(65534)
subject      = "/CN=Black Hat Ruby/O=OffensiveRuby/OU=wwww.blackhatruby.com/C=US"
cert.subject = OpenSSL::X509::Name.parse(subject)
cert.issuer  = cert.subject
cert.public_key = rsa.public_key
cert.not_before = Time.now
cert.not_after  = cert.not_before + 63072000

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate  = cert
cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
cert.add_extension(ef.create_extension("authorityKeyIdentifier", "keyid:always", false))
cert.sign(rsa, OpenSSL::Digest::SHA512.new)

# Another way -The Easy way-
require 'webrick/ssl' # or use: require 'webrick/https'
cert, rsa = WEBrick::Utils.create_self_signed_cert(2048, [["CN", "www.blackhatruby.com"]], 'My valiable Comment')

puts "[+] Self-Signed Certificate: #{dir}/cert.pem"
File.write("./#{dir}/cert.pem", cert.to_pem)

puts "[+] Self-Signed Certificate: #{dir}/cert.der"
File.write("./#{dir}/cert.der", cert.to_der)

puts "[+] Self-Signed Certificate(Password: P@ssw0rd): #{dir}/priv.pfx12"
pfx = OpenSSL::PKCS12.create('P@ssw0rd', 'BlackHatRuby Cert', rsa, cert)
File.write("./#{dir}/pkcs12.pfx12", Base64.encode64(pfx.to_der))

