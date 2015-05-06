class HitsByDay < ActiveRecord::Base
  self.table_name = 'hits_by_day'

  def self.hash_by_day(date, source_name = nil, tracker_name = nil)
    items = HitsByDay .select(assemble_select_param source_name, tracker_name)
                      .joins(assemble_joins_param)
                      .group(assemble_group_param source_name, tracker_name)
                      .where(assemble_where_param date, source_name, tracker_name)

    group_results items, source_name, tracker_name
  end

  def self.assemble_select_param(source_name, tracker_name)
    select_param   = 'orders_by_day.source_display_name, '
    select_param  += 'orders_by_day.tracker_name, ' unless source_name.nil?
    select_param  += 'sum(hits_by_day.hits) AS number_of_hits'

    select_param
  end

  def self.assemble_joins_param
    joins_param  = 'INNER JOIN orders_by_day '
    joins_param += 'ON hits_by_day.tracker_name = orders_by_day.tracker_name '
    joins_param += 'AND hits_by_day.destination_name = orders_by_day.destination_name '
    joins_param += 'AND hits_by_day.created_at = orders_by_day.created_at'

    joins_param
  end

  def self.assemble_group_param(source_name, tracker_name)
    group_param  = 'orders_by_day.source_display_name'
    group_param += ', orders_by_day.tracker_name' unless source_name.nil?

    group_param
  end

  def self.assemble_where_param(date, source_name, tracker_name)
    where_param = { hits_by_day: { created_at: date } }
    where_param[:orders_by_day] = { source_name: source_name } unless source_name.nil?

    where_param
  end

  def self.group_results(items, source_name, tracker_name)
    response  = {}

    if source_name.nil?
      items.each { |item| response[item.source_display_name]  = item.number_of_hits }
    elsif tracker_name.nil?
      items.each { |item| response[item.tracker_name]  = item.number_of_hits }
    else
      debug "Elsão!"
    end

    response
  end
end
