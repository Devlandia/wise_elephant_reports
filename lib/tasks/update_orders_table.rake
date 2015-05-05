namespace :db do
  desc 'Populate orders table with today infos. Inform date as yyyy-mm-dd.'
  task :update_orders_table, [:day] do |t, args|
    include Report::MysqlConnection

    # This vars will be used to register activity log.
    table_name      = 'orders_by_day'
    registers_found = 0
    registers_done  = 0
    log_message     = ''
    current_item    = nil

    begin
      # Define today if is informed as param
      today = args[:day].nil? ? Time.new.strftime('%Y-%m-%d') : Date.parse(args[:day]).strftime('%Y-%m-%d')

      # Check if todays data already exists
      query   = "SELECT count(0) AS total FROM reports.orders_by_day WHERE created_at = '#{today}' LIMIT 1"
      result  = reports_client.query(query, symbolize_keys: true).first[:total]
      fail "Data to #{today} already exists." unless result == 0

      # Read all items for today
      query   = assemble_orders_search_query(today)
      results = wiseleph_hattan_client.query query, symbolize_keys: true

      registers_found = results.size
      results.each do |item|
        current_item  = item
        query         = assemble_orders_insert_query(item)
        reports_client.query query

        registers_done += 1
      end

      log_message = 'ERROR! Registers found != registers done' if registers_found != registers_done
    rescue => e
      log_message = e.message
    end

    begin
      log_result table_name, registers_found, registers_done, log_message
    rescue => e
      puts "\n"
      puts "====> FAIL TO LOG"
      puts "Date: #{today}"
      puts "Table Name: #{table_name}"
      puts "Item: #{current_item}"
      puts e.message
      puts '#' * 50
      p e
      puts '#' * 50
    end
  end
end

def assemble_orders_insert_query(item)
<<EOF
INSERT INTO reports.orders_by_day (
  destination_id,
  tracker_id,
  order_type,
  created_at,
  tracker_name,
  tracker_url,
  destination_name,
  destination_url,
  platform_name,
  platform_url,
  source_name,
  source_display_name,
  number_of_orders,
  value_of_orders
)
VALUES (
  #{item[:destination_id]},
  #{item[:tracker_id]},
  "#{item[:order_type]}",
  "#{item[:created_at].strftime('%Y-%m-%d')}",
  "#{item[:tracker_name]}",
  "#{item[:tracker_url]}",
  "#{item[:destination_name]}",
  "#{item[:destination_url]}",
  "#{item[:platform_name]}",
  "#{item[:platform_url]}",
  "#{item[:source_name]}",
  "#{item[:source_display_name]}",
  #{item[:number_of_orders]},
  #{item[:value_of_orders]}
);
EOF
end

def assemble_orders_search_query(today)
<<EOF
SELECT
  CONVERT(t3.id, UNSIGNED INTEGER) AS destination_id,
  CONVERT(t2.id, UNSIGNED INTEGER) AS tracker_id,
  t1.type AS order_type,
  DATE(t1.created) AS created_at,

  t2.tracker_name,
  t2.tracker_url,

  t3.destination_name,
  t3.destination_url,

  t4.platform AS platform_name,
  t4.site_url AS platform_url,

  t5.type_name AS source_name,
  t5.display_name AS source_display_name,

  COUNT(0) AS number_of_orders,
  SUM(t1.total) AS value_of_orders
FROM
  tusks.sm_orders AS t1
INNER JOIN
  tusks.sm_trackers AS t2 ON t2.id = t1.tracker_id
INNER JOIN
  tusks.sm_destinations AS t3 ON t3.id = t1.destination_id
INNER JOIN
  tusks.sm_platforms AS t4 ON t2.platform_id = t4.id
INNER JOIN
  tusks.sm_sources AS t5 ON t4.source_id = t5.id
WHERE
  DATE(t1.created) = '#{today}'
GROUP BY
  t3.id, t2.id, t1.type, DATE(t1.created), t2.tracker_name, t2.tracker_url, t3.destination_name, t3.destination_url
ORDER BY
  t1.created ASC,
  t2.tracker_name;
EOF
end
