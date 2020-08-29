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
    callbacks.setExtensionName("Scanner2")
    callbacks.registerScannerCheck(self)
  end

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
  end

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

      strust2 = Strust2.new(evil_req_res, @helpers)
      strust2.name       = 'Active Scan'
      strust2.confidence = 'Certain'
      issues.push(strust2.to_java(IScanIssue))
    end

    return issues
  end

  def consolidateDuplicateIssues(existingIssue, newIssue)
    existingIssue.getIssueName == newIssue.getIssueName ? -1 : 0
  end

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

class Strust2
  def self.payload
    <<~PAY
    <map>
      <entry>
        ...
          <command>
            <string>whoami</string>
          </command>
        ...
      </entry>
    </map>
    PAY
  end

  def self.vulnerable?(base_req_res, helpers)
    response = base_req_res.getResponse
    success  = 'java.lang.String cannot be cast to java.security.Provider$Service'.bytes
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
  end

  def getIssueName
    @name = 'BHR | Struts-S2-052 (CVE-2017-9805)' + " | #{@name.to_s}"
  end

  def getIssueType
    @type = 0x00101101
  end

  def getSeverity
    @severity = @severity || 'High'
  end

  def getConfidence
    @confidence = @confidence || "Tentative"
  end

  def getIssueDetail
    @detail = "The response contains the string: 'java.lang.String cannot be cast to java.security.Provider$Service'"
  end

  def getIssueBackground
    @issue_background = <<~EOF
        The REST Plugin is using a XStreamHandler with an instance ....
      EOF
  end

  def getRemediationDetail
    @remediation_detail = <<~EOF
      Upgrade to Apache Struts version 2.5.13 or 2.3.34.
    EOF
  end

  def getRemediationBackground
    @remediation_background = <<~EOF
      Upgrade to Apache Struts version 2.5.13 or 2.3.34.<br>
      ...
    EOF
  end

  def getHttpMessages
    @http_messages = @base_req_res.is_a?(Array) ? @base_req_res : [@base_req_res]
  end

  def getHttpService
    @http_service = @base_req_res.getHttpService
  end
end
