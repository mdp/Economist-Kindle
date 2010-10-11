require 'rubygems'
require 'json'
require '../magazine'
require 'sinatra'

set :haml, {:format => :html5 }

get '/' do
  haml :magazine
end

get '/latest' do
  editions = Dir.glob('editions/*.json')
  current_edition = editions.collect { |e|
      Time.parse(e.gsub('.json', ''))
    }.sort.reverse.first
  json = File.read("editions/#{current_edition.strftime("%d-%b-%Y")}.json")
  content_type 'application/js'
  json
end

get '/current_edition.json' do
  editions = Dir.glob('editions/*.json')
  current_edition = editions.collect { |e|
      Time.parse(e.gsub('.json', ''))
    }.sort.reverse.first
  content_type 'application/js'
  {:current_editions => current_edition.to_s}.to_json
end


get '/manifest' do
  content_type 'text/cache-manifest', :charset => 'utf-8'
  haml :manifest
end
