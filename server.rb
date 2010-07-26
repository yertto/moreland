#!/usr/local/bin/ruby -rrubygems
# A morning's hacked up sinatra app to get an idea of what the data looks like.

require 'sinatra'

require 'db'
require 'server_helper'
require 'planningalerts'


use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', ENV['SITE_PASSWORD']]
end if ENV['SITE_PASSWORD']


create_get '/wards'                , Ward
create_get '/wards/:name'          , Ward
create_get '/reports'              , Report
create_get '/reports/:id'          , Report

get '/reporttypes' do
  haml :reporttypes , :locals => { :reporttypes => Report.subclasses }
end

get '/reporttypes/:type' do
  haml :reports_type , :locals => { :type => eval(params[:type]) }
end

get '/reports/:report_id/pages/:number' do
  haml :page , :locals => { :page => Page.first(
   :report => Report.get(params[:report_id]),
   :number => params[:number]
  ) }
end

create_get '/applications'         , Application
get '/applications/*' do
  haml :application , :locals => { :application => Application.get(params[:splat]) }
end

get '/addresses/:suburb/:street/:number' do
  haml :address, :locals => { :address => Address.first(params) }
end

get '/addresses/:suburb/:street' do
  haml :street , :locals => { :street => params[:street] , :suburb => params[:suburb]}
end

get %r{/addresses/(\d{4})} do |postcode|
  haml :postcode , :locals => { :postcode => postcode }
end

get '/addresses/:suburb' do
  haml :suburb , :locals => { :suburb => params[:suburb] }
end

get '/postcodes' do
  # XXX is there a more efficient way of doing this?
  postcodes = Address.all.collect { |ad| ad.postcode }
  haml :postcodes, :locals => { :postcodes => Hash[postcodes.zip(suburbs)].keys }
end

get '/suburbs' do
  # XXX is there a more efficient way of doing this?
  suburbs = Address.all.collect { |ad| ad.suburb }
  haml :suburbs, :locals => { :suburbs => Hash[suburbs.zip(suburbs)].keys }
end

get '/streets' do
  # XXX is there a more efficient way of doing this?
  streets = Address.all.collect { |ad| [ad.street, ad.suburb] }
  haml :streets, :locals => { :streets => Hash[streets.zip(streets)].keys }
end

get '/addresses' do
  haml :addresses, :locals => { :addresses => Address.all }
end

get '/eventtypes' do
  haml :eventtypes, :locals => { :eventtypes => ApplicationEvent.properties[:event].options[:flags] }
end

get '/eventtypes/:event' do
  haml :eventtype, :locals => { :eventtype => params[:event].to_sym }
end

get '/statuses' do
  statuses = ApplicationEvent.all.collect { |ev| ev.status }
  haml :statuses, :locals => { :statuses => Hash[statuses.zip(statuses)].keys.compact.sort }
end

get '/statuses/:status' do
  haml :status, :locals => { :status => params[:status].to_sym }
end

get '/planningalerts.xml' do
  date = Date.strptime("#{params[:year]}-#{params[:month]}-#{params[:day]}", '%Y-%m-%d') unless params[:year].nil?
  Application.to_planningalerts(date)
end

get '/' do
  redirect '/reports'
end

__END__


@@ _event_a
- if event.page.nil?
  event.event
- else
  %a(href="/reports/#{event.page.report_id}/pages/#{event.page.number}")= event.event


@@ _number_th
%th
  %a(href='/applications') Number


@@ _application_a
%a(href="/applications/#{application.number}" title='#{application.description}')= application.number

@@ _application_table
%table
  %tr
    = haml :_number_th
    = haml :_address_th
    %th= haml :_wards_all
    %th
      %a(href='/eventtypes') Events count
  - applications.each do |application|
    %tr
      %td= haml :_application_a , :locals => { :application => application }
      = haml :_address_td , :locals => { :address => application.address }
      %td= haml :_ward_a , :locals => { :ward => application.address.ward }
      %td= application.application_events.count


@@ _application_event_table
%table
  %tr
    = haml :_number_th
    = haml :_address_th
    %th= haml :_wards_all
    = haml :_event_th
    %th= haml :_status_all_a
    %th Date
  - application_events.all(:order => [:date]).each do |ev|
    %tr
      %td= haml :_application_a , :locals => { :application => ev.application }
      = haml :_address_td , :locals => { :address => ev.application.address }
      %td= haml :_ward_a , :locals => { :ward => ev.application.address.ward }
      %td= haml :_event_a , :locals => { :event => ev }
      %td= haml :_status_a , :locals => { :status => ev.status }
      %td= ev.date


@@ _applications_all
%a(href='/applications') Application


@@ _application
%h3
  = haml :_applications_all
  = ": #{application.number}"
%p
  %b Description:
  = application.description
- if application.applicant
  %p
    %b Applicant:
    = application.applicant
%div
  %b Events:
  = haml :_application_event_table , :locals => { :application_events => application.application_events }


@@ application
= haml :_application, :locals => { :application => application }


@@ applications
%h3 All applications
%div= haml :_application_table, :locals => { :applications => applications }


@@ _wards_all
%a(href='/wards') Ward


@@ _ward_table
%ul
  - wards.each do |ward|
    %li= haml :_ward_a , :locals => { :ward => ward }


@@ ward
%h3
  = haml :_wards_all
  = ": #{ward}"
%div= haml :_application_table, :locals => { :applications => Application.all(:address => Address.all(:ward => ward)) }


@@ wards
%h3 All wards
%div= haml :_ward_table, :locals => { :wards => Ward.all }


@@ _reports_all
%a(href='/reports') Report


@@ _report_table
%table
  %tr
    %th Date
    %th= haml :_reports_all
    %th Pages
    %th Rows
  - reports.each do |report|
    %tr
      %td= report.date
      %td= report.class
      - page_count = report.pages.count
      - error = report.page_count != page_count
      %td
        %a(href="/reports/#{report.id}")= "#{page_count}#{'*' if error}"
      %td= report.pages.application_events.count


@@ _page_a
%a(href="/reports/#{page.report_id}/pages/#{page.number}")= "Page #{page.number} of #{page.report.page_count}"


@@ _report_h
%h3
  %a(href='/reports') Report
  = ": (#{report.date}) #{report.title}"


@@ _event_th
%th
  %a(href='/eventtypes') Event


@@ _eventtype_a
%a(href="/eventtypes/#{eventtype}")= eventtype


@@ eventtype
%h3
  %a(href='/eventtype') Event
  = ": #{eventtype}"
= haml :_application_event_table , :locals => { :application_events => ApplicationEvent.all(:event => eventtype) }


@@ eventtypes
%h3 All event types
%ul
  - eventtypes.each do |eventtype|
    %li
      %a= haml :_eventtype_a , :locals => { :eventtype => eventtype }


@@ _address_th
%th(colspan=5)
  %a(href='/addresses')= Address


@@ _address_td
- rowspan = 1 if rowspan.nil?
%td(rowspan=rowspan)= haml :_address_a , :locals => { :address => address }
%td(rowspan=rowspan)= haml :_street_a  , :locals => { :street => address.street, :suburb => address.suburb }
%td(rowspan=rowspan)= haml :_suburb_a  , :locals => { :suburb => address.suburb }
%td(rowspan=rowspan)= address.state
%td(rowspan=rowspan)= haml :_postcode_a , :locals => { :postcode => address.postcode }


@@ _address_table
%table
  %tr
    = haml :_address_th
    %th= haml :_wards_all
    %th= haml :_applications_all
    %th Event Count
  - addresses.each do |address|
    %tr
      - rowspan = address.applications.count
      = haml :_address_td , :locals => { :address => address , :rowspan => rowspan }
      %td(rowspan=rowspan)= haml :_ward_a , :locals => { :ward => address.ward }
      - address.applications.each do |application|
        - if application == address.applications.first
          %td= haml :_application_a , :locals => { :application => application }
          %td= application.application_events.count
        -else
          %tr
            %td= haml :_application_a , :locals => { :application => application }
            %td= application.application_events.count


@@ page
= haml :_report_h, :locals => { :report => page.report }
%div.page
  %a(href="/reports/#{page.report_id}/pages/#{page.number-1}")= "&lt" unless page.number == 1
  = "Page #{page.number} of #{page.report.page_count}"
  %a(href="/reports/#{page.report_id}/pages/#{page.number+1}")= "&gt;" unless page.number == page.report.page_count
%table
  %tr
    = haml :_number_th
    = haml :_address_th
    %th= haml :_wards_all
    = haml :_event_th
    %th Status
    %th Date
  - page.application_events.each do |ev|
    %tr
      %td= haml :_application_a , :locals => { :application => ev.application }
      = haml :_address_td  , :locals => { :address => ev.application.address }
      %td= haml :_ward_a   , :locals => { :ward => ev.application.address.ward }
      %td= haml :_event_a  , :locals => { :event => ev }
      %td= haml :_status_a , :locals => { :status => ev.status }
      %td= ev.date


@@ report
= haml :_report_h, :locals => { :report => report }
%ul
- report.pages.each do |page|
  %li= haml :_page_a, :locals => { :page => page }


@@ reports_type
%h3= "#{type} reports"
%div= haml :_report_table, :locals => { :reports => type.all }


@@ reports
%h3 All reports
%div= haml :_report_table, :locals => { :reports => reports }


@@ reporttypes
%h3 All reports types
%table
  %tr
    %th Type
    %th Count
  - reporttypes.each do |r|
    %tr
      %td
        %a(href="/reporttypes/#{r}")= r
      %td= r.count


@@ _suburb_a
%a(href="/addresses/#{suburb}")= suburb


@@ suburb
%h3
  %a(href='/suburbs') Suburb
  = ": #{suburb}"
%div= haml :_address_table, :locals => { :addresses => Address.all(:suburb => suburb) }


@@ suburbs
%h3 All Suburbs
%ul
  - suburbs.each do |suburb|
    %li= haml :_suburb_a , :locals => { :suburb => suburb }


@@ _postcode_a
%a(href="/addresses/#{postcode}")= postcode


@@ postcode
%h3
  %a(href='/postcodes') Postcode
  = ": #{postcode}"
%div= haml :_address_table, :locals => { :addresses => Address.all(:postcode => postcode) }


@@ postcodes
%h3 All Postcodes
%ul
  - postcodes.each do |postcode|
    %li= haml :_postcode_a , :locals => { :postcode => postcode }


@@ _street_a
%a(href="/addresses/#{suburb}/#{street}")= street


@@ street
%h3
  %a(href='/streets') Street
  = ": #{street} #{suburb}"
%div= haml :_address_table, :locals => { :addresses => Address.all(:street => street, :suburb => suburb) }


@@ streets
%h3 All Streets
%ul
  - streets.each do |street, suburb|
    %li
      = haml :_street_a , :locals => { :street => street , :suburb => suburb }
      = haml :_suburb_a , :locals => { :suburb => suburb }


@@ _address_a
%a(href="/addresses/#{address.suburb}/#{address.street}/#{address.number}")= address.number


@@ address
%h3
  %a(href='/addresses') Address
  = ": #{address.number} #{address.street} #{address.suburb}"
%div= haml :_address_table, :locals => { :addresses => Address.all(:street => address.street, :suburb => address.suburb, :number => address.number) }


@@ addresses
%h3 All Addresses
%ul
  - addresses.each do |address|
    %li= haml :_address_a , :locals => { :address => address }


@@ _status_a
%a(href="/statuses/#{status}")= status


@@ _status_all_a
%a(href='/statuses') Status


@@ status
%h3
  = haml :_status_all_a
  = ": #{status}"
= haml :_application_table , :locals => { :applications => ApplicationEvent.all(:status => status).collect { |ev| ev.application }.sort }


@@ statuses
%h3 All statuses
%table
  - statuses.each do |status|
    %tr
      %td= "#{ApplicationEvent.all(:status => status).application.count}"
      %td
        %a= haml :_status_a , :locals => { :status => status }


@@ _footer
%footer
  %div.wrapper
    %p
      Powered by
      %a{:href=>"http://github.com/yertto/moreland/blob/v#{MY_VERSION}/server.rb"} this code
      , data from
      %a{:href=>"http://moreland.vic.gov.au/building-and-planning/planning/planning-permit-applications.html"} Moreland Council
      , hosted by
      %a{:href=>"http://heroku.com"} heroku
      ,
      %a{:href=>"http://twitter.com/yertto"}
        %img{:src=>"http://twitter-badges.s3.amazonaws.com/t_mini-a.png", :alt=>"Follow yertto on Twitter"}
  :javascript
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-17640048-1']);
    _gaq.push(['_trackPageview']);
    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();



@@ layout
%html
  %head
    %title Moreland Planning
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/css/main.css', :media => 'screen projection'}
  %body
    = yield
    = haml :_footer
