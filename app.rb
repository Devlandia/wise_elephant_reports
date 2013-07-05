require "rubygems"
require "sinatra/base"

class App < Sinatra::Base

  get '/' do
    'Hello, nginx and unicorn!'
  end

  get '/hello/:name' do
    "Hello #{params[:name]}"
  end
end
