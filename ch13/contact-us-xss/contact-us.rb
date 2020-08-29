#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   A vlnerable Web Application with Blind Stored XSS
# Requirements:
#   gem install sinatra rerun
#   ruby contact-us.rb
#
require 'bundler/inline'

begin
  require 'sinatra'
rescue LoadError
  gemfile do
    source 'https://rubygems.org'
    gem    'sinatra', require: true
  end
rescue
  puts "[!] Please install required gem(s)"
  puts "gem install sinatra rerun"
end

$user     = 'admin'
$pass     = 'admin'
$messages = []

configure {
  set :port, 8181
  set :environment, :production
}

enable :sessions

get '/' do
  erb :contactus
end

post '/contact' do
  sanitized = params.transform_values { |str| anti_xss(str) }
  $messages << sanitized
  "<center><h2>Thank you #{params['firstname']} for contacting us!.</h2>" +
  "The <b>admin</b> will contact you back asap." +
  "<br><a href='/'><b>Back to Home</b></a></center>"
end

get '/login' do
  erb :login	  # page with auth form
end

post '/login' do
  if authenticate(params['username'], params['password'])
    redirect '/admin'
  else
    erb :login
  end
end

get '/admin' do
  if $authorized
    erb :admin
  else
    # erb :admin
    erb :login
  end
end

def authenticate(user, pass)
  if (user == $user) && (pass == $pass)
    $authorized = true
  else
    $authorized = false
  end
end

# Bad Blacklist
def anti_xss(string)
  blacklist = [
    /(<\/script)>/,    # remove: </script> tag
    /(alert\(.+\))/,   # remove: alert()
    /(prompt\(.+\))/,  # remove: prompt()
    /(")/,             # remove: "
    /(">)/             # remove: ">
  ].shuffle

  string.gsub(blacklist.sample, '')
end

before do
  headers "BlackHatRuby"     => "Chapter 14 | XSS"
  headers "X-XSS-Protection" =>  '0'
  headers "Content-Type"     => "text/html; charset=utf-8"
end
