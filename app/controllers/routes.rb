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
    debug params
    @title    = 'All Traffic'
    #@date     = Date.parse params[:date]
    @url      = 'source'
    @group    = 'Source'
    @filters  = parse_filters params

    if @filters[:start_date].blank?
      @errors = 'Please set Start Date at least'
      @data   = {}
    else
      @data   = compose_view_hash(OrdersByDay.dashboard(@filters))
      @total  = count_totals @data
    end

    erb :report
  end

  get '/source/:name/date/:date' do
    @title  = "Source #{params['name']}"
    @date   = Date.parse params[:date]
    @url    = 'tracker'
    @group  = 'Tracker'

    begin
      @data = compose_view_hash(OrdersByDay.from_source(params['name'], params['date']))
      @total  = count_totals @data
    rescue => e
      @error = e.message
    end

    erb :report
  end

  get '/tracker/:name/date/:date' do
    @title  = params['name']
    @date   = Date.parse params[:date]
    @url    = nil
    @group  = 'Destination'

    begin
      @data = compose_view_hash(OrdersByDay.from_tracker(params['name'], params['date']))
      @total  = count_totals @data
    rescue => e
      @error = e.message
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
