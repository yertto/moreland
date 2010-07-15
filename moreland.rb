#!/usr/bin/ruby -rrubygems
require 'pathname'

require 'grid'
require 'fixes'  # really ugly hard-coded fixes
require 'fixes_description'  # really ugly hard-coded fixes
require 'db'

require 'logger'

LOGGER = Logger.new(STDOUT)

class Address
  def self.re
    @re ||= Regexp.compile('^(Rear |ST MATTHEW\'S |SHOP |\'THE GATEHOUSE\' |\'THE LAUNDRY\' |PENTRIDGE (?:PIAZZA )?|)((?:Lot [0-9A-J]*)|[-/0-9A-K]+) (.*?) ([ A-Z]+?) (VIC) (\d{4})$')
  end

  def self.parse(buf)
    buf = fix_address(buf)
    if m = re.match(buf.strip)
      Hash[[:name, :number, :street, :suburb, :state, :postcode].zip(m.captures)]
    else
      puts $line_cache
      raise LOGGER.error "Couldn't parse street: #{buf.inspect}"
    end
  end

  def my_valid?
    warn("ERROR in #{self.class.name.inspect}: #{inspect}") unless (number and street and suburb and state and postcode) # and ward)   XXX - should check ward
  end
end


class Application
  def my_valid?
    address.nil? ? warn("ERROR in #{self.class.name.inspect}, no associated address: #{inspect}") : address.my_valid?
  end
end


class ApplicationEvent

  # XXX refactor candidate
  def self.parse(lines, report, page)
    _item = Grid::Text.new
    lines.each { |line|
      #p line
      line = fix_line(line)
                                                            # XXX - use a case?
      if m = line.match(/^Ward\s+(.*)/)
        report.wards << Ward.first_or_new(:name => m[1])
      elsif line.strip.size == 0
      elsif m = line.match(/\s+Total for this ward :\s+(\d+)/)
        report.wards.last.total = m[1]
        # don't forget the last one
        if _item.started?
          report.new_application_event(_item, page) # XXX - repeated code
          _item = Grid::Text.new                            # XXX - repeated code
        end
      else
        _more_item = report.parse(line)
        if _more_item.started? and _item.started?
          report.new_application_event(_item, page) # XXX - repeated code
          _item = Grid::Text.new                            # XXX - repeated code
        end
        _item += _more_item
      end
    }
    # don't forget the last one
    if _item.started?
          report.new_application_event(_item, page) # XXX - repeated code
    end
  end

  def my_valid?
    application.nil? ? warn("ERROR in #{self.class.name.inspect}, no associated application: #{inspect}") : application.my_valid?
  end
end


class Ward
  attr_accessor :total
end


class Page
  attr_accessor :application_event_count, :_ap_nos

  # XXX - hehe found a bug in ruby here...
  # ie.
  # [1,2,2,2,3]-[1,3]
  # => [2, 2, 2]
  # [1,2,2,2,3]-[1,2,3]
  # => []
  def my_valid?
    application_events.each { |ev| ev.my_valid? }

    ap_nos = application_events.collect { |ap| ap.application_number }
                                                  # XXX - use a case?
    if application_event_count > application_events.count
      diff = self._ap_nos - ap_nos
      if diff == []
        warn "WARNING in #{report.class.name.inspect} report, missing application events for page #{number}: #{application_event_count} > #{application_events.count} #{(self._ap_nos - ap_nos).inspect} (probably because there was a duplicate application event on this page - i.e. not *our* fault.)"
      else
        warn "ERROR in #{report.class.name.inspect} report, missing application events for page #{number}: #{application_event_count} > #{application_events.count} #{(self._ap_nos - ap_nos).inspect}"
      end
    elsif application_events.count > application_event_count 
      warn "ERROR in #{report.class.name.inspect} report, extra application events for page #{number}: #{application_events.count} > #{application_event_count} #{(ap_nos - self._ap_nos).inspect}"
    elsif application_event_count == application_events.count
      true
    else
      raise "ERROR unreachable"
    end
  end
end


class ApplicationNumber
  def self.re2
    @re2 || Regexp.compile("\s*#{re.source[1..-2]}  \s*")  # used for scanning in grid (NB. two following spaces
                                                           # to eliminate false matches in description column)
  end
end

class Report

  attr_accessor :application_event_count

  def remap_attributes(attributes)
    # for the decided subdivisions report, don't know *exactly* what to do with
    # (:latest_decision, :decision_date) and (:soc_issued, :soc_date) attributes.
    attributes.delete(:soc_issued) if attributes[:soc_issued].nil?
    attributes.delete(:soc_date)   if attributes[:soc_issued].nil?

    Hash[
      attributes.collect { |heading, value|
        h = case heading.to_s
        when /number/
             :number
        when /date/
             # Grrr.. crappy american date formatting
             value = Date.strptime(value, fmt='%d/%m/%Y')
             :date
        when /status/
             :status
        when /decision$/
             :status
        when 'address'
             value = Address.parse(value)
             :address
        when 'soc_issued'
             :status
        when 'soc_date'
             value = Date.strptime(value, fmt='%d/%m/%Y')
             :date
        else
             heading
        end
        [h, value]
      }
    ]
  end

  def self.report_type
    name.downcase.to_sym
  end

  def new_application_event(grid, page)
    cols = remap_attributes(grid.attributes(unpacker))
    cols[:date] = date if cols[:date].nil?  # XXX some events don't have a date , so just use the report's date.
    cols[:ward] = wards.last.name if wards.count > 0
    cols[:ward] = 'unknown' if cols[:ward].nil?
    ward = wards.count == 0 ? Ward.first_or_create(:name => cols[:ward]) : wards.last
    address = page.report.council.addresses.first_or_new(cols[:address])
    address.ward = ward
    cols[:description] = fix_description(cols[:description])
    app = Application.first_or_create(  # XXX
      { :number => cols[:number] },
      Application.properties.inject({:address => address}) { |h, prop|
        h[prop.name] = cols[prop.name] unless cols[prop.name].nil?;  h }
    )
    app_event_key = {
      :application => app, :event => self.class.report_type , :status => cols[:status], :date => cols[:date] }
    page.application_events.first_or_new(
      app_event_key, 
      ApplicationEvent.properties.inject(app_event_key) { |h, prop|
        h[prop.name] = cols[prop.name] unless cols[prop.name].nil?; h }
    )
  end

  def unpacker
    @unpacker ||= Grid::Unpacker.new(self.class.header_re)
  end

  def parse(line)
    Grid::Text.parse(line, unpacker)
  end

  def self.get_lines(page_)
    lines = page_.split("\n")
  end

  # XXX refactor candidate
  def self.breakup(page_)
    page_info = {}
    lines = get_lines(page_)

    # get title
    unless header_re.match(lines.first)  # App progress report is weird
      page_info[:title] = lines.delete(lines.first)
    end

    # get page info
    if m = /(.*?)\s+Page (\d+) of (\d+)/.match(lines.last)
      page_info[:date], page_number, page_info[:page_count] = m.captures
      lines.delete(lines.last)
    end

    # get dates
    if m = /where (?:received|advertised|decision) date between (\d+\/\d+\/\d{4}) and (\d+\/\d+\/\d{4})/.match(lines.first)
      # Grrr.. crappy american date formatting
      page_info[:date_from] = Date.strptime(m[1], fmt='%d/%m/%Y')
      page_info[:date_to  ] = Date.strptime(m[2], fmt='%d/%m/%Y')
      lines.delete(lines.first)
    else
      page_info[:date_from] = page_info[:date]   # XXX - don't know what to do with missing dates :(
      page_info[:date_to  ] = page_info[:date]   # XXX - don't know what to do with missing dates :(
    end

    # remove empty lines
    while lines.first.strip.size == 0
      lines.delete(lines.first)
    end if lines.first

    # heading line is the first line
    heading_line = lines.delete(lines.first)

    return [page_number, page_info, heading_line, lines]  # XXX - should probably use an object here
  end

  # XXX - refactor candidate
  def self.parse(f)
    f = Pathname.new(f) unless f.is_a? Pathname
    puts "Processing #{f} ..."
    pages_ = f.read.split("")
    
    report = nil
    pages_.collect { |page_|
      page_number, page_info, heading_line, lines = self.breakup(page_)
      
      if lines.size > 0
        if report.nil?
          report = first(:date => page_info[:date])
          return report unless report.nil?    # XXX - ugly
          report = new(page_info)
          report.council = Council.first_or_create(:name => 'Moreland')
          #report.save
          #p report
          report.application_event_count = 0
        end

        page = report.pages.first_or_new(:number => page_number)  # XXX Page.first_or_create

        # *rough* way of getting number of application events per page (later used in my_valid? check)
        page._ap_nos = page_.scan(ApplicationNumber.re2).collect { |m| m[0] }
        report.application_event_count += page.application_event_count = page._ap_nos.size

        # align the unpacker
        report.unpacker.align(heading_line)

        # parse lines to return application events
#        page.application_events = ApplicationEvent.parse(lines, report)
        ApplicationEvent.parse(lines, report, page)

        #report.pages << page
        puts page
      else
        nil
      end
    }.compact

    report.save
    return report
  end

  def my_valid?
    LOGGER.info "  validating report..."
    pages.each { |page| page.my_valid? }
    warn "ERROR in #{self.class.name.inspect} report, number of pages: #{pages.count} != #{page_count}" if pages.count != page_count
    warn "ERROR in #{self.class.name.inspect} report, number of application events: #{application_events2.size} != #{application_event_count}" if application_events2.size != application_event_count
  end

  before :save do
    p valid?
    p my_valid?
    LOGGER.info "  saving #{self.class.name} report (?finally? writing to the database, which takes *some* time) ..."
  end

end


#
# Report subclasses
#
# (NB. ruby has another ugly little bug with class variables
# ( ie. overriding a variable in a child alos modifies the parent  - so haven't used them here!)
class Received #< Report
  def self.header_re
    @header_re ||= /(Application_Number\s*)(Date Received\s*)(Address\s*)Description/
  end
end

class Updated #< Report
  def self.header_re
    @header_re ||= /(Application Number\s*)(Address\s*)(Description\s*)Status_Description/
  end
end

class UpdatedSubdivisions < Updated
  def self.report_type; :updated; end
  def self.header_re
    @header_re ||= /(Application Number\s*)(Address\s*)(Description\s*)Status/
  end
end

class Advertised #< Report
  def self.header_re
    @header_re ||= /(App. Number\s*)(Description\s*)(Address\s*)Advertised Date/
  end
end

class Decided #< Report
  def self.header_re
    @header_re ||= /(Ward\s*)(Decision\s*)(Decision Date\s*)(Application Number\s*)(Address\s*)Description/
  end
end
class Decided2 < Decided
  def self.report_type; :decided; end
  def self.header_re
    @header_re ||= /(Ward\s*)(Decision\s*)(Decision Date\s*)(Application Number\s*)(Address\s*)(Applicant\s*)Description/
  end
end

class DecidedSubdivisions #< Report
  def self.report_type; :decided; end
  def self.header_re
    @header_re ||= /(Application Number\s*)(Address\s*)(Description\s*)(Latest Decision\s*)(Decision Date\s*)(SOC Issued\s*)SOC Date/
  end
end


if __FILE__ == $0
  report =            Received.parse('test_data/received.txt'             ); puts report ; report.save
  report =          Advertised.parse('test_data/advertised.txt'           ); puts report ; report.save
  report =             Updated.parse('test_data/updated.txt'              ); puts report ; report.save
  report = UpdatedSubdivisions.parse('test_data/updated_subdivisions.txt' ); puts report ; report.save
  report =             Decided.parse('test_data/decided.txt'              ); puts report ; report.save
  report = DecidedSubdivisions.parse('test_data/decided_subdivisions.txt' ); puts report ; report.save
end

