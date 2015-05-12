class HitsByDay < ActiveRecord::Base
  self.table_name = 'hits_by_day'

  def self.hash_by_day(params)
    start_date    = params.has_key?(:start_date)    ? params[:start_date]   : nil
    end_date      = params.has_key?(:end_date)      ? params[:end_date]     : nil
    source_name   = params.has_key?(:source_name)   ? params[:source_name]  : nil
    tracker_name  = params.has_key?(:tracker_name)  ? params[:tracker_name] : nil
    level         = params.has_key?(:level)         ? params[:level]        : 'dashboard'

    items = HitsByDay .select(assemble_select_param level)
                      .joins(assemble_joins_param)
                      .group(assemble_select_param level)
                      .where(assemble_where_param level, start_date, end_date, source_name, tracker_name)

    group_results items, level, source_name, tracker_name
  end

  def self.assemble_select_param(level)
    select_param   = 'orders_by_day.source_display_name, '
    select_param  += 'orders_by_day.tracker_name, '     if level == 'source'
    select_param  += 'orders_by_day.destination_name, ' if level == 'tracker'
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

  def self.assemble_where_param(level, start_date, end_date, source_name, tracker_name)
    response  = nil
    vars      = []

    if end_date.nil?
      response = "hits_by_day.created_at = ?"
      vars << start_date
    else
      response = "hits_by_day.created_at >= ? AND hits_by_day.created_at <= ?"
      vars << start_date
      vars << end_date
    end

    unless source_name.nil?
      response += " AND orders_by_day.source_name = ?"
      vars << source_name
    end

    unless tracker_name.nil?
      if level == 'tracker'
        response += " AND orders_by_day.tracker_name = ?"
        vars << tracker_name
      else
        response += " AND orders_by_day.tracker_name LIKE ?"
        vars << "%#{tracker_name}%"
      end
    end

    [response] + vars
  end

  def self.group_results(items, level, source_name, tracker_name)
    if level == 'dashboard'
      key = 'source_display_name'
    elsif level == 'source'
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
