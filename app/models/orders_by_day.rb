class OrdersByDay < ActiveRecord::Base
  self.table_name = 'orders_by_day'

  has_many :hits_by_day, class_name: 'HitsByDay', foreign_key: [:tracker_name, :destination_name, :created_at]

  def self.dashboard(date)
    # Group by source type to informed day
    items = OrdersByDay .select('source_name, source_display_name, order_type, created_at, sum(number_of_orders) AS number_of_orders, sum(value_of_orders) AS value_of_orders')
                        .where(created_at: date)
                        .group('source_name, source_display_name, order_type, created_at')

    assemble_dashboard_hash items
  end

  def self.from_source(source_display_name, date)
    params    = { 'source_display_name' => source_display_name, 'created_at' => date }
    items     = filter params

    assemble_from_source_hash items
  end

  def self.tracker(params = {})
    items     = filter params
    response  = { tracker_name: '', tracker_url: '', hits: 0, convertions: 0, upsells: 0, total_upsells: 0, sales: 0, total_sales: 0 }

    return response if items.blank?

    item  = items.first

    response[:tracker_name] = item.tracker_name
    response[:tracker_url]  = item.tracker_url
    response.merge! sumarize(items)

    response.to_json
  end

  def self.assemble_dashboard_hash(items)
    response  = {}
    split     = {}
    template  = { hits: 0, conversions: 0, avg_order_value: 0 }

    # Build a hash with default template to each source]
    items.each { |item| split[item.source_display_name] = [] }

    # Split items into sources
    items.each { |item| split[item.source_display_name] << item }

    # Mount hits hash
    hits_hash = HitsByDay.hash_by_day items.first.created_at

    # Sumarize for upsells and sales
    split.each do |key, items|
      response[key] = template.merge(sumarize(items))
      response[key] = calculate_avgs(response[key], hits_hash[key]) if hits_hash.has_key?(key)
    end

    response
  end

  def self.assemble_from_source_hash(items)
    response  = {}
    split     = {}
    template  = { hits: 0, conversions: 0, avg_order_value: 0 }

    # Build a hash with default template to each source]
    items.each { |item| split[item.tracker_name] = [] }

    # Split items into sources
    items.each { |item| split[item.tracker_name] << item }

    # Mount hits hash
    hits_hash = HitsByDay.hash_by_day items.first.created_at, items.first.source_name

    # Sumarize for upsells and sales
    split.each do |key, items|
      response[key] = template.merge(sumarize(items))
      response[key] = calculate_avgs(response[key], hits_hash[key]) if hits_hash.has_key?(key)
    end

    response
  end

  def self.filter(params = {})
    where(assemble_filters(params))
  end

  def self.assemble_filters(params)
    filters = {}

    filters[:tracker_id]          = params['tracker_id'].to_i                       if params.key? 'tracker_id'
    filters[:destination_id]      = params['destination_id'].to_i                   if params.key? 'destination_id'
    filters[:order_type]          = params['order_type']                            if params.key? 'order_type'
    filters[:created_at]          = Date.strptime(params['created_at'], '%Y-%m-%d') if params.key? 'created_at'
    filters[:source_display_name] = params['source_display_name'] if params.key? 'source_display_name'

    filters
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

  def self.calculate_avgs(item, hits)
    item[:hits]             = hits
    item[:conversions]      = 100 * item[:sales] / item[:hits]
    item[:avg_order_value]  = (item[:total_upsells] + item[:total_sales]) / (item[:upsells] + item[:sales])

    item
  end
end
