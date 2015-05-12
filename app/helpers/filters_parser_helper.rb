module FiltersParser
  def parse_filters(level, params = {})
    response      = {}
    start_date    = params[:start_date]

    response[:start_date]   = start_date.blank? ? Time.new.strftime('%Y-%m-%d') : start_date
    response[:end_date]     = params[:end_date]

    if level == 'source'
      response[:source_display_name]  = params[:source_display_name]
    end

    if level == 'tracker'
      response[:tracker_name] = params[:tracker_name]
    else
      response[:tracker_name] = params[:tracker_name]
    end

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
