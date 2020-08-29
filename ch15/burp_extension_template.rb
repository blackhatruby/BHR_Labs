#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Burp Extension Template
# Requirements:
#   jruby | jruby-code-xxx-complete.jar
#   Burp Suite
#
require 'java'

java_import 'burp.IBurpExtender'

class BurpExtender
  include IBurpExtender

  def registerExtenderCallbacks(callbacks)
    # Your Extension Ruby Code Here
  end
end
