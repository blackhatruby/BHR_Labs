# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Script to read the extracted database from 'Easy File Sharing Web Server'
# Requirements: 
#   gem install sqlite3
# 
require "sqlite3"

userdb = ARGV[0]
db     = SQLite3::Database.open(userdb)
users  = db.execute("SELECT id, userid, passwd, email, level FROM sqltable")
users.each do |user| 
  puts "#{user[0]}) ".ljust(4) +  "#{user[1]} ".ljust(15) + "#{user[2]}".ljust(15) + "#{user[3]}"
end

puts 
