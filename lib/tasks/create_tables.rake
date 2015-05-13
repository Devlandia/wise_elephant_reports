namespace :db do
  task :create_tables do
    include Report::MysqlConnection

    create_hits_by_day reports_client
    create_orders_by_day reports_client
    create_import_logs reports_client
  end
end

def create_hits_by_day(client)
    query =<<EOF
CREATE TABLE mastodon.hits_by_day (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_at date DEFAULT NULL,
  tracker_name varchar(70) CHARACTER SET utf8 DEFAULT NULL,
  destination_name varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  hits INTEGER NOT NULL DEFAULT -1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF
    client.query query

    query = "CREATE INDEX reports_hits_by_day_created_at_idx ON mastodon.hits_by_day(created_at) USING BTREE;"
    client.query query

    query = "CREATE INDEX reports_hits_by_day_created_at_tracker_name_idx ON mastodon.hits_by_day(created_at, tracker_name) USING BTREE"
    client.query query
end

def create_orders_by_day(client)
    query =<<EOF
CREATE TABLE orders_by_day (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  destination_id int(11) unsigned NOT NULL,
  tracker_id int(11) unsigned NOT NULL,
  order_type varchar(999) DEFAULT 'parent',
  created_at date DEFAULT NULL,
  tracker_name varchar(1000) DEFAULT NULL,
  tracker_url varchar(1000) DEFAULT NULL,
  destination_name varchar(1000) DEFAULT NULL,
  destination_url varchar(1000) DEFAULT NULL,
  platform_name varchar(1000) DEFAULT NULL,
  platform_url varchar(1000) DEFAULT NULL,
  source_name varchar(1000) DEFAULT NULL,
  source_display_name varchar(255) NOT NULL,
  number_of_orders bigint(21) NOT NULL,
  value_of_orders double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF
    client.query query

    query = 'CREATE INDEX reports_order_by_day_order_type_idx ON mastodon.orders_by_day(order_type) USING BTREE;';
    client.query query

    query = 'CREATE INDEX reports_order_by_day_destination_id_idx ON mastodon.orders_by_day(destination_id) USING BTREE;';
    client.query query

    query = 'CREATE INDEX reports_order_by_day_tracker_id_idx ON mastodon.orders_by_day(tracker_id) USING BTREE;';
    client.query query
end

def create_import_logs(client)
    query =<<EOF
CREATE TABLE mastodon.daily_import_logs(
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_at timestamp default now(),
  table_name VARCHAR(100) NOT NULL,
  registers_found INTEGER NOT NULL,
  registers_done INTEGER NOT NULL,
  log_message TEXT
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
EOF
    client.query query
end
