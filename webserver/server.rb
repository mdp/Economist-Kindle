require 'rubygems'
require '../magazine'
require 'sinatra'

set :haml, {:format => :html5 }

get '/latest.html' do
  mag = Magazine.load(Time.parse('2010-05-15'))
  mag.html 
end

get '/anifest' do
  content_type 'text/cache-manifest', :charset => 'utf-8'
  haml :manifest
end
