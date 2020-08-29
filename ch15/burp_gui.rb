#!/usr/bin/env ruby
# ========================================================= #
# This file is a part of { Black Hat Ruby } book lab files. #
# ========================================================= #
#
# Author:
#   Sabri Hassanyah | @KINGSABRI
# Description:
#   Burp extension that is heavily depends on GUI components
# Requirements:
#   jruby | jruby-code-xxx-complete.jar
#   Burp Suite
#

# Ruby requires
require 'java'

module JPackages
  # Java's Interfaces
  include_package javax.swing
  include_package 'javax.swing.border'
  include_package java.awt
  # Burp's Interfaces
  include_package 'burp'
  include IBurpExtender
  include IContextMenuFactory
  include IContextMenuInvocation
  include ITab
end

class Object
  def self.const_missing(class_name) JPackages.const_get(class_name); end
end


#
# GUI Factory
#
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

class BurpExtender
  include JPackages
  include GUI

  def registerExtenderCallbacks(callbacks)
    @callbacks     = callbacks
    extension_name = 'BlackHat Ruby'
    @callbacks.setExtensionName("#{extension_name} | GUI Extension")

    @itab = JTabbedPane.new
    @itab_caption = 'Black Hat Ruby | iTab'

    @callbacks.customizeUiComponent(@itab)
    @callbacks.addSuiteTab(self)

    panel = JPanel.new
    @itab.addTab('Black Hat Ruby | SubTab', panel)

    label_title = '<html><h1>' + "Black Hat Ruby | Label" + '</h1></html>'
    label_col = Color.new(255, 102, 0)
    label = JLabel.new
    label.setText(label_title)
    label.setForeground(label_col)
    label.setToolTipText("Where Ruby Goes Evil!")

    panel.setBorder(
      BorderFactory.createTitledBorder(
        nil, label_title,
        TitledBorder::LEFT,
        TitledBorder::TOP,
        Font.new("Times New Roman", 1, 20),
        Color.new(255, 102, 0))
    )

    @callbacks.registerContextMenuFactory(self)

    extension_info(extension_name)
    greeting(extension_name)
  end

  # Context menu
  def createMenuItems(invocation)
    book_modules = [
      'Module 1| Introduction',
      'Module 2| Hacker’s everyday codes in Ruby',
      'Module 3| System Hacking',
      'Module 4| Network Hacking',
      'Module 5| Web Hacking',
      'Module 6| Exploitation'
    ]

    # Create Section menu (contains sub-menus)
    main_menu = JMenu.new('<html><b>Black Hat Ruby | Modules Menu</b></html>')
    book_modules.each do |mod|
      item = JMenuItem.new(mod)
      item.addActionListener {                             # Create a regular menuitem
        showMessageDialog({title: mod, message: "#{current_context(invocation)}", level: 1})
      }
      main_menu.add(item)                                  # Add it to it's parent, the section menu
    end

    [main_menu]
  end

  # https://portswigger.net/burp/extender/api/burp/IContextMenuInvocation.html
  def current_context(invocation)
    case invocation.invocation_context
    # CONTEXT_INTRUDER_ATTACK_RESULTS
    when 9 then "You're in an Intruder attack results"
    # CONTEXT_INTRUDER_PAYLOAD_POSITIONS
    when 8 then "You're in the Intruder payload positions editor"
    # CONTEXT_MESSAGE_EDITOR_REQUEST
    when 0 then "You're in a request editor"
    # CONTEXT_MESSAGE_EDITOR_RESPONSE
    when 1 then "You're in a response editor"
    # CONTEXT_MESSAGE_VIEWER_REQUEST
    when 2 then "You're in a non-editable request viewer"
    # CONTEXT_MESSAGE_VIEWER_RESPONSE
    when 3 then "You're in a non-editable response viewer"
    # CONTEXT_PROXY_HISTORY
    when 6 then "You're in the Proxy history"
    # CONTEXT_SCANNER_RESULTS
    when 7 then "You're in the Scanner results"
    # CONTEXT_SEARCH_RESULTS
    when 10 then "You're in a search results window"
    # CONTEXT_TARGET_SITE_MAP_TABLE
    when 5 then "You're in the Target site map table"
    # CONTEXT_TARGET_SITE_MAP_TREE
    when 4 then "You're in the Target site map tree"
    else
      "Oh, how did you get there?"
    end
  end

  def getTabCaption
    @itab_caption
  end

  # ITab::getUiComponent
  def getUiComponent
    @itab
  end

  # Popup window, welcome!
  def greeting(extension_name)
    type, major_v, minor_v = @callbacks.get_burp_version
    showMessageDialog(
      { title: "Welcome to #{extension_name}",
        message:
                "Thank you for installing #{extension_name}!\n\n" +
                '- Burp Type: '    + "#{type}\n" +
                '- Burp Version: ' + "#{major_v}.#{minor_v}",
        level: 1
      }
    )
  end

  def extension_info(extension_name)
    msg = "[+] Great! you've installed '#{extension_name}' successfully!\n" +
          "-"*100 + "\n" +
          "Extension: #{extension_name} Extension\n" +
          "Author   : Sabri Hassanyah | @KINGSABRI\n" +
          "WebSite  : http://BlackHatRuby.com\n"
    puts msg
  end

end
