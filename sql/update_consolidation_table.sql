START TRANSACTION;
	INSERT INTO reports.orders_by_day
		SELECT
			CONVERT(t3.id, UNSIGNED INTEGER) AS destination_id,
			CONVERT(t2.id, UNSIGNED INTEGER) AS tracker_id,
			t1.type AS order_type,
			DATE(t1.created) AS created_at,

			t2.tracker_name,
			t2.tracker_url,

			t3.destination_name,
			t3.destination_url,

			t4.platform	AS platform_name,
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
			DATE(t1.created) = '2015-04-28'
		GROUP BY
			t3.id, t2.id, t1.type, DATE(t1.created), t2.tracker_name, t2.tracker_url, t3.destination_name, t3.destination_url
		ORDER BY
			t1.created ASC,
			t2.tracker_name;
COMMIT;