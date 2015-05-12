module ViewVarsParser
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

  def view_items(level, filters)
    filters[:level] = level

    if level == 'dashboard'
      OrdersByDay.dashboard filters
    else
      OrdersByDay.from_orders filters
    end
  end
end
