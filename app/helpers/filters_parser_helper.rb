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

  def parse_period(params)
    response    = ''

    unless params[:start_date].blank?
      start_date   = Date.parse params[:start_date] 
      response    += "From #{start_date.strftime('%d/%m/%Y')} "
    end

    unless params[:end_date].blank?
      end_date    = Date.parse params[:end_date] 
      response    += "until #{end_date.strftime('%d/%m/%Y')}"
    end

    response
  end

  def view_items(level, filters)
    if level == 'dashboard'
      OrdersByDay.dashboard filters
    elsif level == 'source'
      OrdersByDay.from_source filters
    else
      OrdersByDay.from_tracker filters
    end
  end

  def set_view_attrs(level, params)
    @filters      = parse_filters level, params
    @query_params = compose_filters_param @filters
    @period       = parse_period @filters

    if @filters[:start_date].blank?
      @errors = 'Please set Start Date at least'
      @data   = {}
    else
      @data   = compose_view_hash(view_items(level, @filters))
      @total  = count_totals @data
    end
  end
end
