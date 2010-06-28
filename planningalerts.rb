#!/usr/local/bin/ruby -rrubygems
require 'nokogiri'

require 'db'


class Application
  def self.to_planningalerts(date = nil)
    # XXX - haven't tested date searching, and should put date in some kind of where clause
    applications = all

    Nokogiri::XML::Builder.new { |xml|
      xml.planning {
        xml.authority_name 'Moreland City Council, VIC'
        xml.authority_short_name 'Moreland'
        xml.applications {
          applications.each { |app|
            if date.nil? or ( app.advertised_date and app.advertised_date <= date )
              xml.application {
                xml.council_reference app.number
                xml.address           app.address.to_s.upcase
                xml.description       app.description
               #xml.info_url
               #xml.comment_url
                xml.date_received     app.received.date   unless app.received.nil?
                xml.on_notice_from    app.advertised.date unless app.advertised.nil?
                xml.on_notice_to      app.decided.date    unless app.decided.nil?
              } if date.nil? or app.decided.nil? or (app.decided_date and app.decided_date >= date)
            end
          }
        }
      }
    }.to_xml
  end

  def received
    @received ||= application_events.first(:event => :received)
  end

  def advertised
    @advertised ||= application_events.first(:event => :advertised)
  end
  def advertised_date
    advertised.date unless advertised.nil?
  end

  def decided
    @decided ||= application_events.first(:event => :decided)
  end
  def decided_date
    decided.date unless decided.nil?
  end
end


if __FILE__ == $0
  puts Application.to_planningalerts(Date.parse('2010-05-01'))
end
