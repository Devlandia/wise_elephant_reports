# encoding: utf-8

require 'date'
require 'active_support/all'

APPLICATION_PATH  = File.expand_path(File.dirname(__FILE__))
require "#{APPLICATION_PATH}/app/helpers/mysql_connection_helper.rb"
require "#{APPLICATION_PATH}/lib/debug.rb"

include Report::MysqlConnection

current_day = tusks_client.query('SELECT min(created) AS min FROM sm_orders').first['min']
limit_day   = Time.new - 1.day

while current_day <= limit_day
  system "rake db:update_hits_table[#{current_day.strftime('%Y-%m-%d')}]"
  system "rake db:update_orders_table[#{current_day.strftime('%Y-%m-%d')}]"

  current_day += 1.day
end
