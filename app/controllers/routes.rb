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

  def count_totals(items)
    response  = { hits: 0, conversions: 0, upsells: 0, sales: 0, total_upsells: 0, total_sales: 0, avg_order_value: 0 }

    items.each { |source, values| values.each { |key, value| response[key] += value } }

    total_orders  = response[:sales] + response[:upsells] + 0.0
    value_orders  = response[:total_upsells] + response[:total_sales] + 0.0

    response[:conversions]      = response[:hits] == 0  ? 0 : total_orders / response[:hits]
    response[:avg_order_value]  = total_orders == 0     ? 0 : value_orders / total_orders

    response
  end

  # Frontent
  get '/dashboard/:date' do
    @title  = 'All Traffic'
    @date   = Date.parse params[:date]
    @url    = 'source'
    @group  = 'Source'

    begin
      @data   = OrdersByDay.dashboard(params['date'])
      @total  = count_totals @data
    rescue => e
      @error = e.message
    end

    erb :dashboard
  end

  get '/source/:name/date/:date' do
    @title  = "Source #{params['name']}"
    @date   = Date.parse params[:date]
    @url    = 'tracker'
    @group  = 'Tracker'

    begin
      @data = OrdersByDay.from_source(params['name'], params['date'])
      @total  = count_totals @data
    rescue => e
      @error = e.message
    end

    erb :dashboard
  end

  get '/tracker/:name/date/:date' do
    @title  = params['name']
    @date   = Date.parse params[:date]
    @url    = nil
    @group  = 'Destination'

    begin
      @data = OrdersByDay.from_tracker(params['name'], params['date'])
      @total  = count_totals @data
    rescue => e
      @error = e.message
    end

    erb :dashboard
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
