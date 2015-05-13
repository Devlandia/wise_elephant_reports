class OrdersByDay < ActiveRecord::Base
  self.table_name = 'orders_by_day'

  has_many :hits_by_day, class_name: 'HitsByDay', foreign_key: [:tracker_name, :destination_name, :created_at]

  def self.dashboard(params)
    validate_params params

    # Group by source type to informed day
    items = OrdersByDay .select('source_name, source_display_name, order_type, created_at, sum(number_of_orders) AS number_of_orders, sum(value_of_orders) AS value_of_orders')
                        .where(assemble_where params)
                        .group('source_name, source_display_name, order_type, created_at')

    split     = assemble_split_hash(items, 'source_display_name')
    hits_hash = HitsByDay.hash_by_day params

    assemble_response hits_hash, split
  end

  def self.from_orders(params = {})
    validate_params params

    items     = where assemble_where(params)
    grouper   = params[:level] == 'source' ? 'tracker_name' : 'destination_name'
    split     = assemble_split_hash items, grouper
    hits_hash = HitsByDay.hash_by_day params

    assemble_response hits_hash, split
  end

  def self.validate_params(params)
    fail 'Start date not informed'  unless params.has_key? :start_date

    if params[:level] == 'dashboard'
      fail 'End date not informed'    unless params.has_key? :end_date
    elsif params[:level] == 'source'
      fail 'Source display name invalid'  unless params.has_key? :source_display_name
    else
      fail 'Tracker name invalid' unless params.has_key?  :tracker_name
    end
  end

  def self.assemble_where(params)
    response  = nil
    vars      = []

    if params[:end_date].blank?
      response = "created_at = ?"
      vars << params[:start_date]
    else
      response = "created_at >= ? AND created_at <= ?"
      vars << params[:start_date]
      vars << params[:end_date]
    end

    if params.has_key? :source_display_name
      response += " AND source_display_name = ?"
      vars << params[:source_display_name]
    end

    unless params[:tracker_name].blank?
      if params[:level] == 'tracker'
        response += " AND orders_by_day.tracker_name = ?"
        vars << params[:tracker_name]
      else
        response += " AND orders_by_day.tracker_name LIKE ?"
        vars << "%#{params[:tracker_name]}%"
      end
    end

    [response] + vars
  end

  def self.assemble_split_hash(items, key)
    split     = {}

    items.each { |item| split[eval "item.#{key}"] = [] }
    items.each { |item| split[eval "item.#{key}"] << item }

    split
  end

  def self.assemble_response(hits_hash, split)
    response  = {}
    template  = { hits: 0, conversions: 0, avg_order_value: 0 }

    split.each do |key, items|
      response[key] = template.merge(sumarize(items))
      response[key] = calculate_avg(response[key])
      response[key] = calculate_conversions(response[key], hits_hash[key]) if hits_hash.has_key?(key)
    end

    response
  end

  def self.sumarize(items)
    response  = { upsells: 0, total_upsells: 0, sales: 0, total_sales: 0 }

    items.each do |item|
      if item.order_type == 'upsell'
        response[:upsells]        += item.number_of_orders
        response[:total_upsells]  += item.value_of_orders
      else
        response[:sales]          += item.number_of_orders
        response[:total_sales]    += item.value_of_orders
      end
    end

    response
  end

  def self.calculate_avg(item)
    item[:avg_order_value]  = item[:total_sales] / item[:sales]

    item
  end

  def self.calculate_conversions(item, hits)
    item[:hits]             = hits
    item[:conversions]      = 100 * item[:sales] / item[:hits]

    item
  end
end
