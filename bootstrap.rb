# encoding: utf-8

require 'rubygems'
require 'sinatra/base'
require 'sinatra/activerecord'

set :database_file, "#{APPLICATION_PATH}/config/database.yml"

# Require app/models
Dir["#{APPLICATION_PATH}/app/models/*.rb"].each { |file| require file }
