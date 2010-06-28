require 'dm-core'
require 'dm-types'
require 'dm-migrations'

DataMapper::Logger.new(STDOUT, :debug) if ENV['DEBUG']
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:///#{Dir.pwd}/devel.db")


class ApplicationNumber < DataMapper::Type  # NB. causes an erroneous deprecation warning in dm v1.0.0
  primitive       String
  length          16   # XXX - sqlite is ignoring this :(
  auto_validation true # XXX - sqlite is ignoring this :(

  def self.re
    @re ||= Regexp.compile('^((MPS|SP|SC|MIN)/\d{4}/\d+(?:/([A-K]))?)$')
  end

  def self.dump(value, property)
    return nil unless value
    raise "ERROR bad #{name}: #{value.inspect}" unless re.match(value)
    value.to_s
  end

  def self.load(value, property)  # (2010/06/18 dm documentation needs updating ... doesn't mention "property" arg)
    value
  end
end


class Council
  include DataMapper::Resource 
  property :name , String ,:key => true

  has n, :addresses
  has n, :reports
end


class Address
  include DataMapper::Resource 

  property :id       , Serial
  property :number   , String
  property :street   , String
  property :suburb   , String
  property :state    , String
  property :postcode , Integer

  belongs_to :council
  belongs_to :ward
  has     n, :applications

  default_scope(:default).update(:order => [:state, :suburb, :street, :number]) 

  def to_s
    #"#{number} #{street} #{suburb}"# #{state} #{postcode}"
    "#{number} #{street} #{suburb} #{state} #{postcode}"
  end
end


class Ward
  include DataMapper::Resource

  property :name  , String  , :key => true

  has n, :addresses
  #has n, :reports      , :through => ReportWard
  has n, :reports      , :through => Resource

  default_scope(:default).update(:order => :name) 

  def to_s
    name
  end
end


class ApplicationEvent
  include DataMapper::Resource 

  property :id                 , Serial
  property :application_number , ApplicationNumber
  property :date               , Date              #, :required => false # XXX - nullable?
  property :status             , String
  property :event              , Enum[
   :received, :updated, :advertised, :decided]

  belongs_to :application
  belongs_to :page

  # keep the order that appeared in the report
  #default_scope(:default).update(:order => [:application_number, :date]) 
  # keep the order that appeared in the report

  def to_s
    "(#{event}:#{status} #{date})"
  end
end

class Application
  include DataMapper::Resource 

  property :number      , ApplicationNumber , :key => true
  property :description , Text              , :length => 50

  belongs_to :address
  has n    , :application_events

  default_scope(:default).update(:order => [:number]) 

  def to_s
    "<##{self.class.name}: #{number} : #{application_events.last} : #{address} : #{address.ward} : #{'%-20s' % description}}>"
  end
end


class Page
  include DataMapper::Resource
  
  property :report_id          , Integer       , :key => true
  property :number             , Integer       , :key => true

  belongs_to :report
  has n    , :application_events

  default_scope(:default).update(:order => [:report_id, :number]) 

  def to_s
    "<##{self.class.name} #{report.report_type} #{report.date}: Page #{number} of #{report.page_count} (#{application_events.count} application events)>"
  end
end

=begin
class ReportWard
  include DataMapper::Resource

  belongs_to :reports
  belongs_to :wards
end
=end


class Report
  include DataMapper::Resource

  property :id          , Serial
  property :date        , Date          #, :key => true
  property :report_type , Discriminator #, :key => true
  property :title       , Text
  property :date_from   , Date
  property :date_to     , Date
  property :page_count  , Integer

  belongs_to :council
  has n, :pages
  #has n, :wards        , :through => ReportWard
  has n, :wards        , :through => Resource

  default_scope(:default).update(:order => [:date, :report_type]) 

  has n, :application_events , :through => :pages
  def application_events2
    # XXX - chaining associations doesn't work until the objects have been saved to the database...
    pages.collect { |page| page.application_events }.flatten
  end

  def to_s
    #"<##{self.class.name} Report: #{title} : #{date} : (#{date_from} - #{date_to}) (#{page_count} pages) (#{application_events.count} application events)>" #+ "\n #{pages.join("\n  ")}"
    "<##{self.class.name} Report: #{title} : #{date} : (#{date_from} - #{date_to}) (#{page_count} pages) (#{application_events2.size} application events)>" #+ "\n #{pages.join("\n  ")}"
  end
end

#
# Report subclasses
#
class Received < Report; end
class Updated < Report; end
class UpdatedSubdivisions < Updated; end
class Advertised < Report; end
class Decided < Report; end
class DecidedSubdivisions < Report; end


DataMapper.auto_upgrade!
