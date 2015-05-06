namespace :db do
  desc 'Populate hits table with today infos. Inform date as yyyy-mm-dd.'
  task :update_hits_table, [:day] do |t, args|
    include Report::MysqlConnection

    # This vars will be used to register activity log.
    table_name      = 'hits_by_day'
    registers_found = 0
    registers_done  = 0
    log_message     = ''
    current_item    = nil

    begin
      # Define today if is informed as param
      today = args[:day].nil? ? Time.new.strftime('%Y-%m-%d') : Date.parse(args[:day]).strftime('%Y-%m-%d')

      # Check if todays data already exists
      query   = "SELECT count(0) AS total FROM reports.hits_by_day WHERE created_at = '#{today}' LIMIT 1"
      result  = reports_client.query(query, symbolize_keys: true).first[:total]
      fail "Data to #{today} already exists." unless result == 0

      # Read all items for today
      query   = assemble_hits_search_query(today)
      results = wiseleph_hattan_client.query query, symbolize_keys: true

      registers_found = results.size
      results.each do |item|
        current_item  = item
        query = assemble_hits_insert_query(item)
        reports_client.query query

        registers_done += 1
      end

      log_message = 'ERROR! Registers found != registers done' if registers_found != registers_done
    rescue => e
      log_message = e.message
    end

    begin
      log_result today, table_name, registers_found, registers_done, log_message
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

def assemble_hits_insert_query(item)
<<EOF
  INSERT INTO reports.hits_by_day
    (created_at, tracker_name, destination_name, hits)
  VALUES
    ("#{item[:created_at].strftime("%Y-%m-%d")}", "#{item[:tracker_name]}", "#{item[:destination_name]}", #{item[:hits]})
EOF
end

def assemble_hits_search_query(today)
<<EOF
SELECT
  created_at,
  tracker_name,
  destination_name,
  count(0) AS hits
FROM
  (SELECT
    idvisitor,
    DATE(visit_first_action_time) AS created_at,
    referer_name AS tracker_name,
    referer_keyword AS destination_name
  FROM
    wiseleph_hattan.piwik_log_visit as t1
  WHERE
    # hairlavie has idsite = 1
    # If is necessary data from all sites, it's just remove this
    # condition, make a join with piwik_site table and put on select
    # and group condition.
    idsite = 1
  AND
    visit_first_action_time >= '#{today} 00:00:00'
  AND
    visit_first_action_time <= '#{today} 23:59:59'
  AND
    referer_name != ''
  AND
    referer_keyword != ''
  GROUP BY
    idvisitor,
    created_at,
    referer_name,
    referer_keyword
) AS t2
GROUP BY
  created_at,
  tracker_name,
  destination_name
ORDER BY
  tracker_name,
  destination_name;
EOF
end
