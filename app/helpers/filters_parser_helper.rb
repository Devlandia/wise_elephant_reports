module FiltersParser
  def parse_dashboard_filters(params = {})
    response      = {}
    start_date    = params[:start_date]

    response[:start_date]   = start_date.blank? ? Time.new.strftime('%Y-%m-%d') : start_date
    response[:end_date]     = params[:end_date]
    response[:tracker_name] = params[:tracker_name]

    response
  end

  def parse_source_filters(params = {})
    response                        = parse_dashboard_filters params
    response[:source_display_name]  = params[:source_display_name]

    response
  end

  def parse_tracker_filters(params = {})
    response                = parse_tracker_filters params
    response[:tracker_name] = params[:tracker_name]

    response
  end

  def compose_filters_param(filters)
    response = ""

    filters.each do |key, value|
      unless value.blank?
        response += response.blank? ? '?' : '&'
        response += "#{key}=#{value}"
      end
    end

    response
  end
end
