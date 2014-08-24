#!env ruby
require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'coffee-script'

get '/' do
  slim :index
end

get '/*.css' do |path|
  scss path.to_sym, :style => :expanded
end

get '/*.js' do |path|
  coffee path.to_sym
end
