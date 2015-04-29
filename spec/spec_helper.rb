# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'rubygems'
require 'sinatra'

APPLICATION_PATH  = File.expand_path(File.dirname(__FILE__) + '/../')
require File.expand_path '../../app.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() App end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

def debug(params)
  params  = [params] unless params.is_a?(Array)

  puts "\n\n"
  puts '#' * 200
  params.each do |param|
    p param
    puts '#' * 200
  end
  puts "\n\n"
end
