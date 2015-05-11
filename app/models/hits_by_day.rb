class HitsByDay < ActiveRecord::Base
  self.table_name = 'hits_by_day'

  def self.hash_by_day(date, source_name = nil, tracker_name = nil)
    items = HitsByDay .select(assemble_select_param source_name, tracker_name)
                      .joins(assemble_joins_param)
                      .group(assemble_select_param source_name, tracker_name)
                      .where(assemble_where_param date, source_name, tracker_name)

    group_results items, source_name, tracker_name
  end

  def self.assemble_select_param(source_name, tracker_name)
    select_param   = 'orders_by_day.source_display_name, '
    select_param  += 'orders_by_day.tracker_name, ' unless source_name.nil?
    select_param  += 'orders_by_day.destination_name, ' unless tracker_name.nil?
    select_param  += 'hits_by_day.hits'

    select_param
  end

  def self.assemble_joins_param
    joins_param  = 'INNER JOIN orders_by_day '
    joins_param += 'ON hits_by_day.tracker_name = orders_by_day.tracker_name '
    joins_param += 'AND hits_by_day.destination_name = orders_by_day.destination_name '
    joins_param += 'AND hits_by_day.created_at = orders_by_day.created_at'

    joins_param
  end

  def self.assemble_where_param(date, source_name, tracker_name)
    where_param = { hits_by_day: { created_at: date } }
    where_param[:orders_by_day] = { source_name: source_name } unless source_name.nil?
    where_param[:orders_by_day][:tracker_name]  = tracker_name unless tracker_name.nil?

    where_param
  end

  def self.group_results(items, source_name, tracker_name)
    if source_name.nil?
      key = 'source_display_name'
    elsif tracker_name.nil?
      key = 'tracker_name'
    else
      key = 'destination_name'
    end

    group_by_key items, key
  end

  def self.group_by_key(items, key)
    response  = {}

    items.each do |item|
      response[eval "item.#{key}"]  = 0 unless response.key?(eval "item.#{key}")
      response[eval "item.#{key}"]  += item.hits
    end

    response
  end
end
