# encoding: utf-8

require "#{APPLICATION_PATH}/bootstrap.rb"
require 'sinatra/reloader'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :development do
    register Sinatra::Reloader
  end

  # Frontent
  get '/dashboard/:date' do
    @title  = 'All Traffic'
    @url    = 'source'
    @date   = Date.parse params[:date]

    begin
      @data = OrdersByDay.dashboard(params['date'])
    rescue => e
      @error = e.message
    end

    erb :dashboard
  end

  get '/source/:name/date/:date' do
    @title  = params['name']
    @date   = Date.parse params[:date]
    @url    = 'tracker'

    begin
      @data = OrdersByDay.from_source(params['name'], params['date'])
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

  get '/orders' do
    begin
      { status: true, orders: OrdersByDay.filter(params) }.to_json
    rescue => e
      { status: false, message: e.message }.to_json
    end
  end

  get '/report/tracker/:id/:created_at' do
    begin
      { status: true, data: OrdersByDay.tracker(params) }.to_json
    rescue => e
      { status: false, message: e.message }.to_json
    end
  end
end
