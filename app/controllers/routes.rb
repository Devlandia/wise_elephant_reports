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

  # Frontent
  get '/dashboard' do
    @title        = 'All Traffic'
    @url          = 'source'
    @group        = 'Source'
    @filters      = parse_filters 'dashboard', params
    @query_params = compose_filters_param @filters

    if @filters[:start_date].blank?
      @errors = 'Please set Start Date at least'
      @data   = {}
    else
      @data   = compose_view_hash(OrdersByDay.dashboard(@filters))
      @total  = count_totals @data
    end

    erb :report
  end

  get '/source/:source_display_name' do
    @title        = "Source #{params['name']}"
    @url          = 'tracker'
    @group        = 'Tracker'
    @filters      = parse_filters 'source', params
    @query_params = compose_filters_param @filters

    if @filters[:start_date].blank?
      @errors = 'Please set Start Date at least'
      @data   = {}
    else
      @data   = compose_view_hash(OrdersByDay.from_source(@filters))
      @total  = count_totals @data
    end

    erb :report
  end

  get '/tracker/:tracker_name' do
    @title        = params['name']
    @url          = nil
    @group        = 'Destination'
    @filters      = parse_filters 'tracker', params
    @query_params = compose_filters_param @filters

    if @filters[:start_date].blank?
      @errors = 'Please set Start Date at least'
      @data   = {}
    else
      @data = compose_view_hash(OrdersByDay.from_tracker(@filters))
      @total  = count_totals @data
    end

    erb :report
  end

  # API
  get '/health' do
    "I'm OK"
  end

  # Show all sources and its respective values
  # to a date.
  # http://localhost:8080/report/dashboard/date/2015-04-25
  get '/report/dashboard/date/:date' do
    begin
      { status: true, data: OrdersByDay.dashboard(params['date']) }.to_json
    rescue => e
      { status: false, message: e.message }.to_json
    end
  end

  # Show all orders and upsells from a source to a date.
  # localhost:8080/report/source/Social%20Media/date/2015-03-19
  get '/report/source/:name/date/:date' do
    begin
      { status: true, orders: OrdersByDay.from_source(params['name'], params['date']) }.to_json
    rescue => e
      { status: false, message: e.message }.to_json
    end
  end

  # Show all orders and upsells from a source to a date.
  # localhost:8080/report/source/Social%20Media/date/2015-03-19
  get '/report/tracker/:name/date/:date' do
    begin
      { status: true, data: OrdersByDay.from_tracker(params['name'], params['date']) }.to_json
    rescue => e
      { status: false, message: e.message }.to_json
    end
  end
end
