class OrdersByDay < ActiveRecord::Base
  self.table_name = 'orders_by_day'

  has_many :hits_by_day, class_name: 'HitsByDay', foreign_key: [:tracker_name, :destination_name, :created_at]

  def self.dashboard(params)
    fail 'Start date not informed'  unless params.has_key? :start_date
    fail 'End date not informed'    unless params.has_key? :end_date

    # Group by source type to informed day
    items = OrdersByDay .select('source_name, source_display_name, order_type, created_at, sum(number_of_orders) AS number_of_orders, sum(value_of_orders) AS value_of_orders')
                        .where(assemble_where params)
                        .group('source_name, source_display_name, order_type, created_at')

    assemble_dashboard_hash items
  end

  def self.from_source(params = {})
    fail 'Start date invalid'           unless params.has_key? :start_date
    fail 'Source display name invalid'  unless params.has_key? :source_display_name

    items       = where assemble_where(params)

    assemble_from_source_hash items
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
      response += " AND orders_by_day.tracker_name LIKE ?"
      vars << "%#{params[:tracker_name]}%"
    end

    [response] + vars
  end

  def self.from_tracker(tracker_name, date)
    params    = { 'tracker_name' => tracker_name, 'created_at' => date }
    items     = filter params

    assemble_from_tracker_hash items
  end

  def self.assemble_dashboard_hash(items)
    return items if items.empty?
    split     = assemble_split_hash(items, 'source_display_name')

    # Mount hits hash
    hits_hash = HitsByDay.hash_by_day items.first.created_at

    # Sumarize for upsells and sales
    assemble_response hits_hash, split
  end

  def self.assemble_from_source_hash(items)
    split     = assemble_split_hash(items, 'tracker_name')

    # Mount hits hash
    hits_hash = HitsByDay.hash_by_day items.first.created_at, items.first.source_name

    # Sumarize for upsells and sales
    assemble_response hits_hash, split
  end

  def self.assemble_from_tracker_hash(items)
    split     = assemble_split_hash(items, 'destination_name')

    # Mount hits hash
    hits_hash = HitsByDay.hash_by_day items.first.created_at, items.first.source_name, items.first.tracker_name

    # Sumarize for upsells and sales
    assemble_response hits_hash, split
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
    item[:avg_order_value]  = (item[:total_upsells] + item[:total_sales]) / (item[:upsells] + item[:sales])

    item
  end

  def self.calculate_conversions(item, hits)
    item[:hits]             = hits
    item[:conversions]      = 100 * item[:sales] / item[:hits]

    item
  end
end
