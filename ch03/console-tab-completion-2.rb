#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Console based tab Completion
# Requirements: 
#   
# 

require 'readline'

# Prevent Ctrl+C for exiting
trap('INT', 'SIG_IGN')

# List of commands
CMDS = [ 'help', 'rubyfu', 'ls', 'exit' ].sort


completion = 
    proc do |str|
      case 
      when Readline.line_buffer =~ /help.*/i
    puts "Available commands:\n" + "#{CMDS.join("\t")}"
      when Readline.line_buffer =~ /rubyfu.*/i
    puts "Rubyfu, where Ruby goes evil!"
      when Readline.line_buffer =~ /ls.*/i
    puts `ls`
      when Readline.line_buffer =~ /exit.*/i
    puts 'Exiting..'
    exit 0
      else
    CMDS.grep( /^#{Regexp.escape(str)}/i ) unless str.nil?
      end
    end


Readline.completion_proc = completion        # Set completion process
Readline.completion_append_character = ' '   # Make sure to add a space after completion

while line = Readline.readline('-> ', true)  # Start console with character -> and make add_hist = true
  puts completion.call
  break if line =~ /^quit.*/i or line =~ /^exit.*/i
end