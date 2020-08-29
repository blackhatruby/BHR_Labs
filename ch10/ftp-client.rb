#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   FTP Client
# Requirements:
#
require 'net/ftp'

ftp = Net::FTP.new('192.168.100.17', 'ftp', 'ftp@123')  # Create New FTP connection
ftp.welcome                                             # The server's welcome message
# ftp.system                                              # Get system information
# ftp.chdir '/tmp/testftp'                                # Change directory
# ftp.pwd                                                 # Get the correct directory
# ftp.list('*')                                           # or ftp.ls, List all files and folders
# ftp.mkdir 'bhr_backup'                                  # Create directory
# ftp.size 'secret.txt'                                   # Get file size
# ftp.get 'secret.txt', 'secret-dst.txt', 1024            # Download file
# ftp.put 'file1.pdf', 'file1.pdf'                        # Upload file
# ftp.rename 'file1.pdf', 'file2.pdf'                     # Rename file
# ftp.delete 'file3.pdf'                                  # Delete file
ftp.quit                                                # Exit the FTP session
ftp.closed?                                             # Is the connection closed?
ftp.close                                               # Close the connection

