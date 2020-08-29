#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Mutiple ways to detect the current Operating System
# Requirements:
#

puts "[+] Using Gem::Platform"
pp Gem::Platform.local
pp Gem::Platform.local.os
pp Gem::Platform.local.cpu
pp Gem.win_platform?

puts "\n[+] Using RUBY_PLATFORM Constant variable"
pp RUBY_PLATFORM

puts "\n[+] Using Platform Environment’s Variables"
require 'rbconfig'
pp RbConfig::CONFIG["host_os"]
pp RbConfig::CONFIG["arch"]

