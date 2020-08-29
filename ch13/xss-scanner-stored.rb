#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Reflected XSS Scanner
# Requirements:
#   gem install watir nokogiri
#   download firefox WebDriver: https://github.com/mozilla/geckodriver/releases
#
require 'watir'
require 'nokogiri'
url      = ARGV[0] || "http://localhost:8181/"
payloads = File.readlines(ARGV[1]||'payloads.txt', chomp: true)

def insertion_points(html)
  inputs = Nokogiri::HTML(html).search('input', 'textarea').map{|node| { (node['type']||node.name) => node['name']} }
  inputs.select{|input| input unless input.values.compact.empty? }
end

def map_type(type)
  {
    'text'     => 'text_field',
    'password' => 'text_field',
    'textarea' => 'textarea'
  }[type]
end

begin
  Selenium::WebDriver::Firefox::Service.driver_path = './geckodriver'
  browser = Watir::Browser.new :firefox

  browser.goto("#{url}/login")
  browser.element(name: 'username').wait_until(&:present?)
  browser.element(name: 'password').wait_until(&:present?)
  browser.element(type: 'submit').wait_until(&:present?)
  browser.text_field(name: 'username').set('admin')
  browser.text_field(name: 'password').set('admin')
  sleep 2
  browser.button(value: 'Login').click
  # pp admin_tab = browser.div(id: 'container').h1(text: 'Admin Page')
  # admin_tab = browser.div(class: 'container').h1(text: 'Admin Page')
  # browser.refresh
  # browser.send_keys(:control, 't')
  # browser.send_keys(:control, 't')
  # puts "send ctrl+t   | Open a new tab"
  # sleep 3
  # browser.send_keys(:control, "\t")
  # puts "send ctrl+tab | Move to the new tab"
  # sleep 3
  # browser.goto(url)
  # # sleep 3
  browser.goto(url)

  payloads.each_with_index do |payload, num|
    payload = payload.gsub('NUM', "#{num+1}")
    insertion_points(browser.html).each do |intry|
      type = map_type(intry.keys[0])
      name = intry.values[0]
      browser.element(name: name).wait_until(&:present?)
      browser.method(type).call(name: name).set(payload)
      sleep 0.2
    end
    browser.element(type: 'submit').wait_until(&:present?)
    browser.button(value: 'Submit').click

    browser.refresh

    if browser.alert.exists?
      puts "[+] Exploit found: #{payload}"
      sleep 1
      browser.alert.ok
    else
      sleep 0.3
    end

    browser.link(text: 'Back to Home').wait_until(&:present?).click
  end

rescue Selenium::WebDriver::Error::UnexpectedAlertOpenError
  puts "[!] It seems there is a modal dialog was open, blocking this operation"
  puts "[!] Previous XSS payload is executed, rerun contact-us.rb"
  browser.alert.ok
rescue Exception => e
  puts e.full_message
ensure
  browser.close
end
