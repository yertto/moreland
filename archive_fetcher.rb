#!/usr/bin/ruby -rrubygems
require 'nokogiri'

require 'fetcher'

module ArchiveFetcher
  extend Fetcher

  def self.pdf_to_txt_file(pdf_file)
    txt_file = Pathname.new((pdf_file.to_s.split('.')[0..-2]+['txt']).join('.'))
    unless txt_file.exist?
      puts "Converting to text #{txt_file} ..."
      `pdftotext -layout #{pdf_file.to_s.inspect} #{txt_file.to_s.inspect}` unless txt_file.exist?
    end
    txt_file
  end

  def self.fetch_files(url, cache_dir)
    doc = Nokogiri.parse(get_data(url, cache_dir)) 
    doc.xpath("//a[contains(@href, '.pdf') and not(contains(@href, 'guide')) and not(contains(@href, 'response')) and not(contains(@href, 'brochure'))]/@href").collect { |x|
      pdf_url = "#{url[0..64]}/#{x.value[3..-1]}"
      cache_file = get_cache_file(pdf_url, cache_dir)
      pdf_to_txt_file(cache_file)
    }
  end
end

if __FILE__ == $0
  %w{
    http://web.archive.org/web/20030113155908/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20030510153331/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20030819024934/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20031027024130/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20040723013018/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20041025120623/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050118013218/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050127033426/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050323214900/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050413045231/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050416083516/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050616120435/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050624083131/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050710081756/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050724084608/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050731100259/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050810083919/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050901075105/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050903135856/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20050907120602/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20051102010614/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20060824114708/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20060918213815/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20070830173833/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20071212040756/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20080120232053/www.moreland.vic.gov.au/services/currentapplications.htm
    http://web.archive.org/web/20080321225557/www.moreland.vic.gov.au/services/currentapplications.htm
  }.each { |url|
    cache_dir = Pathname.new(".cache0/#{url[29..34]}")
    ArchiveFetcher.fetch_files(url, cache_dir)
  }
end

