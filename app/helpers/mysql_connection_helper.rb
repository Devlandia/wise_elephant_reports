require 'mysql2'
require 'yaml'

# Require this on your rake tasks and everything will be fine!
# Use require Report::MysqlConnection and use reports_client as well.
module Report
  module MysqlConnection
    attr_accessor :reports_client
    attr_accessor :wiseleph_hattan_client
    attr_accessor :tusks_client

    def reports_client
      return @reports_client unless @reports_client.nil?

      @reports_client = stablish_reports_connection

      @reports_client
    end

    def wiseleph_hattan_client
      return @wiseleph_hattan_client unless @wiseleph_hattan_client.nil?

      @wiseleph_hattan_client = stablish_wiseleph_hattan_connection

      @wiseleph_hattan_client
    end

    def tusks_client
      return @tusks_client unless @tusks_client.nil?

      @tusks_client = stablish_tusks_connection

      @tusks_client
    end

    def env
      env = ENV['RACK_ENV']
      return env unless env.nil?

      ENV['RAILS_ENV'] || 'development'
    end

    def stablish_connection(configs)
      Mysql2::Client.new configs
    end

    # TODO: Check if file exists
    def config_file
      YAML.load_file "#{APPLICATION_PATH}/config/settings.yml"
    end

    def stablish_reports_connection
      stablish_connection config_file[env]['reports']
    end

    def stablish_wiseleph_hattan_connection
      stablish_connection config_file[env]['wiseleph_hattan']
    end

    def stablish_tusks_connection
      stablish_connection config_file[env]['tusks']
    end

    def log_result(date, table_name, registers_found, registers_done, log_message)
      query = <<EOF
  INSERT INTO mastodon.daily_import_logs
    (created_at, table_name, registers_found, registers_done, log_message)
  VALUES
    ('#{date}', '#{table_name}', #{registers_found}, #{registers_done}, '#{log_message}')
EOF
      reports_client.query query
    end
  end
end
