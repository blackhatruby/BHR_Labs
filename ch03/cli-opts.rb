#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Script to show how to create a script with CLI options and sub commands.
# Requirements: 
# 
require 'optparse'

options = {}

subcmdtext = <<HELP
Available commands:
     creds :\t set user credentials.
   payload :\t set payload value.
See '#{__FILE__} COMMAND --help' for more information on a specific command.
HELP

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options] [subcommand [options]]"
  opts.on('-t', '--target HOST', 'The target hostname or IP address.') do |v|
    options[:target] = v
  end
  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit!
  end
  opts.separator subcmdtext
  opts.separator ""
  opts.on_tail "Examples:"
  opts.on_tail "  #{__FILE__} creds --user-id 500 --password P@ssw0rd@123"
  opts.on_tail "  #{__FILE__} payload --message \"Happy hacking!\""
end

subcommands = { 
  'creds' => OptionParser.new do |opts|
      opts.banner = "Usage: creds [options]"
      opts.on('-u', '--user-id UID', Integer, "The user's ID (UID) to hack.", "  (default: 911)") do |v|
        options[:uid] = v
      end
      opts.on('-p', '--password PASSWORD', "The user's password.") do |v|
        options[:pass] = v
      end
   end,
   'payload' => OptionParser.new do |opts|
      opts.banner = "Usage: payload [options]"
      opts.on("-v", "--value [VALUE]", "The value to inject in the payload.") do |v|
        options[:value] = v
      end
      opts.on("-m", "--message [MESSAGE]", "The payload message.") do |v|
        options[:message] = v
      end
   end
 }

opts.order!
command = ARGV.shift
subcommands[command].order! unless subcommands[command].nil?

pp options
