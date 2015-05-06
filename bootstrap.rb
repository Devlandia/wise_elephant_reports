# encoding: utf-8

require 'rubygems'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'action_view'

set :database_file, "#{APPLICATION_PATH}/config/database.yml"

# Require app/models
Dir["#{APPLICATION_PATH}/app/models/*.rb"].each { |file| require file }

# Require libs
Dir["#{APPLICATION_PATH}/lib/*.rb"].each { |file| require file }
