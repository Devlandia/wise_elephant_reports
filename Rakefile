# The code bellow allows rake to use activerecord
# without rails. It's not necessary now, but still here for eventual needs.
#require 'sinatra/activerecord/rake'
#
#namespace :db do
#  task :load_config do
#    require './app'
#  end
#end

APPLICATION_PATH  = File.expand_path(File.dirname(__FILE__))

require "#{APPLICATION_PATH}/lib/tasks/mysql_connection_helper.rb"

Dir.glob('./lib/tasks/*.rake').each { |r| import r }
