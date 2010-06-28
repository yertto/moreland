#!/usr/bin/ruby -rrubygems
require 'nokogiri'

require 'fetcher'
require 'moreland'

module MorelandFetcher
  extend Fetcher

  URL = 'http://moreland.vic.gov.au/building-and-planning/planning/planning-permit-applications.html'

  def self.pdf_to_txt_file(pdf_file)
    txt_file = Pathname.new((pdf_file.to_s.split('.')[0..-2]+['txt']).join('.'))
    unless txt_file.exist?
      puts "Converting to text #{txt_file} ..."
      `pdftotext -layout #{pdf_file.to_s.inspect} #{txt_file.to_s.inspect}` unless txt_file.exist?
    end
    txt_file
  end

  def self.fetch_files
    doc = Nokogiri.parse(get_data(URL)) 
    doc.xpath("//a[contains(@href, '.pdf')]/@href").collect { |x|
      cache_file = get_cache_file(x.value)
      pdf_to_txt_file(cache_file)
    }
  end
end

if __FILE__ == $0
  files = if ARGV.size > 0
    ARGV.collect { |f|
      f = Pathname.new(f) unless f.is_a? Pathname
      f.extname == '.pdf' ? MorelandFetcher.pdf_to_txt_file(f) : f
    }
  else
    MorelandFetcher.fetch_files
  end

  # XXX only saves the ones that have a current_ward XXX
  files.each { |f|
		report = case f
    when /003(\s|%20)qryplanpermitappnrecdbyward.txt/
      Received
    when /008(\s|%20)planningpermitsinprogress.txt/
      Updated
    when /014(\s|%20)subdivision(\s|%20)certifications(\s|%20)in(\s|%20)progress.txt/
      UpdatedSubdivisions
    when /002(\s|%20)rptplanpermitappnadvbyward.txt/
      Advertised
    when /006(\s|%20)planning(\s|%20)decisions.txt/
      Decided
    when /013(\s|%20)subdivision(\s|%20)certification(\s|%20)decisions.txt/
      DecidedSubdivisions
    else
      warn "ERROR unhandled file: #{f}"
    end
    if report
      puts r = report.parse(f)
      r.save
    end
  }
end

