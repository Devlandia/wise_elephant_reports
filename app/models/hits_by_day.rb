class HitsByDay < ActiveRecord::Base
  self.table_name = 'hits_by_day'

  def self.dashboard_hash(date)
    items = HitsByDay .select('orders_by_day.source_display_name, sum(hits_by_day.hits) AS number_of_hits')
                      .joins('INNER JOIN orders_by_day ON hits_by_day.tracker_name = orders_by_day.tracker_name AND hits_by_day.destination_name = orders_by_day.destination_name AND hits_by_day.created_at = orders_by_day.created_at')
                      .group('orders_by_day.source_display_name')
                      .where(created_at: date)

    response  = {}
    items.each { |item| response[item.source_display_name]  = item.number_of_hits }

    response
  end
end
