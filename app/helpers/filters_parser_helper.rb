module FiltersParser
  def parse_filters(params = {})
    response      = {}
    start_date    = params[:start_date]

    response[:start_date]   = start_date.blank? ? Time.new.strftime('%Y-%m-%d') : start_date
    response[:end_date]     = params[:end_date] 
    response[:tracker_name] = params[:tracker_name]

    response
  end
end
