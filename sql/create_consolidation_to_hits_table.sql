START TRANSACTION;
	CREATE TABLE reports.hits_by_day
		SELECT
			created_at,
			tracker_name,
			destination_name,
			count(0) AS total
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
				# If is necessary data from all sites, its just remove this
				# condition, make a join with piwik_site table and put on select
				# and group condition.
				idsite = 1
			AND
				visit_first_action_time >= '2015-04-21 00:00:00'
			AND
				visit_first_action_time <= '2015-04-21 23:59:59'
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

	CREATE INDEX reports_hits_by_day_order_type_idx ON reports.hits_by_day(created_at) USING BTREE;
	CREATE INDEX reports_hits_by_day_order_type_idx ON reports.hits_by_day(created_at, tracker_name) USING BTREE;
COMMIT;
