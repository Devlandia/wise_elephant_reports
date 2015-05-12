# encoding: utf-8

require "#{APPLICATION_PATH}/bootstrap.rb"
require 'sinatra/reloader'

class Routes < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    register Sinatra::Reloader
  end

  set :root, APPLICATION_PATH
  set :views, "#{APPLICATION_PATH}/app/views"

  include ActionView::Helpers::NumberHelper

  helpers ResultsParser
  helpers FiltersParser
  helpers Partials
  helpers ViewVarsParser

  # Frontent
  get '/dashboard' do
    @title        = 'All Traffic'
    @url          = 'source'
    @group        = 'Source'

    set_view_attrs 'dashboard', params

    erb :report
  end

  get '/source/:source_display_name' do
    @title        = "Source #{params['source_display_name']}"
    @url          = 'tracker'
    @group        = 'Tracker'

    set_view_attrs 'source', params

    erb :report
  end

  get '/tracker/:tracker_name' do
    @title        = params['tracker_name']
    @url          = nil
    @group        = 'Destination'

    set_view_attrs 'tracker', params

    erb :report
  end

  # API
  get '/health' do
    "I'm OK"
  end
end
