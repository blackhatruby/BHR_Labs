# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
# 
# Author: 
#   Sabri Hassanyah | @KINGSABRI
# Description: 
#   Metasploit Auxiliary Module for 'Easy File Sharing Web Server'
# Requirements: 
#   Metasploit framework 
# 
class MetasploitModule < Msf::Auxiliary
  
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Scanner

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Easy File Sharing Web Server Finder',
      'Description'    => %q{
        This module finds Easy File Sharing Web Servers and list the 
        relevant CVE's or exploit-db(EDB) numbers to the discovered versions.
      },
      'Author'         => [ 'Sabri Hassanyah (@KINGSABRI) <King.Sabri[at]gmail.com>' ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          ['EDB', '39008'],
          ['PACKETSTORM', '143382']
        ],
    ))

    register_options([
      OptString.new('TARGETURI', [ true, 'The URI to use', '/']),
      OptEnum.new('HTTP_METHOD', [ true, 'HTTP Method to use, HEAD or GET', 'HEAD', ['GET', 'HEAD'] ])
    ])
  end

  def vulndb(version)
    ref = {
      1 => %w[EDB-23222 EDB-30856 CVE-2006-5715 CVE-2003-1296 CVE-2003-1297].sort.reverse,
      2 => %w[EDB-30856].sort.reverse,
      3 => %w[CVE-2006-1159 CVE-2006-1160 CVE-2006-1161 EDB-30856].sort.reverse,
      4 => %w[EDB-30856 CVE-2009-4809 CVE-2006-5714 CVE-2006-5714 CVE-2006-5713].sort.reverse,
      5 => %w[EDB-30856 PACKETSTORM-99831 PACKETSTORM-99832].sort.reverse,
      6 => %w[CVE-2014-9439 CVE-2014-5178 CVE-2014-3791].sort.reverse,
      7 => %w[CVE-2018-9059 CVE-2014-9439 CVE-2014-5178 CVE-2014-3791].sort.reverse
    }
    ref[version]
  end

  def server_response
    uri    = normalize_uri(target_uri.path)
    method = datastore['HTTP_METHOD']

    vprint_status("#{peer}: requesting #{uri} via #{method}")
    res = send_request_cgi({
      'uri'     => uri,
      'method'  => method
    })

    unless res
      vprint_error("#{peer}: connection timed out")
      return
    end

    headers = res.headers
    if headers
      return headers
    else
      vprint_status("#{peer}: no headers returned")
      return
    end
  end

  def run_host(ip)
    response = server_response 
    return if response.nil?

    header  = response['Server']
    version =  header.match(/\d+/).to_s.to_i

    if header.match? /Easy File Sharing Web Server.*/
      print_good("#{peer}: Vulnerable : #{header}")
      print_good("Related Vulnerabilties:")
      vulndb(version).each {|ref| print_good("    - #{ref}") unless ref.nil?}
    else
      print_warning("Target is not vulnerable")
    end
  end

end
