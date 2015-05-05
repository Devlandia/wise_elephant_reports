require 'rubygems'
require 'sinatra'

APPLICATION_PATH  = File.expand_path(File.dirname(__FILE__))

require "#{APPLICATION_PATH}/app.rb"

run App
