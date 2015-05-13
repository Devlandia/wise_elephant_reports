module ResultsParser
  def count_totals(items)
    response  = { hits: 0, conversions: 0, upsells: 0, sales: 0, total_upsells: 0, total_sales: 0, avg_order_value: 0, hits_to_orders: 0, value_per_hit: 0 }

    items.each { |source, values| values.each { |key, value| response[key] += value } }

    total_orders  = response[:conversions] + response[:upsells] + 0.0
    value_orders  = response[:total_sales] + 0.0

    response[:avg_order_value]  = total_orders == 0     ? 0 : value_orders / total_orders
    response[:hits_to_orders]   = response[:hits] == 0  ? 0 : total_orders / response[:hits]
    response[:value_per_hit]    = response[:hits] == 0  ? 0 : response[:total_sales] / response[:hits]

    response
  end

  def compose_view_hash(items)
    response  = {}

    items.each do |source, values|
      response[source]  = {
        hits:             values[:hits],
        conversions:      values[:sales],
        upsells:          values[:upsells],
        total_upsells:    values[:total_upsells],
        sales:            values[:total_sales],
        total_sales:      values[:total_sales] + values[:total_upsells],
        hits_to_orders:   values[:conversions],
        avg_order_value:  values[:avg_order_value],
        value_per_hit:    0,
      }

      response[source][:value_per_hit]  = values[:total_sales] / values[:hits] unless values[:hits] == 0;
    end

    response
  end
end
