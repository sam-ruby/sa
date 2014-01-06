class BaseController < ApplicationController

  layout 'cad'
  def login_user
    user = User.get_item_with_name(session[:user_id].to_s)
    session[:user_id] = nil if user.to_s.empty?
    return session[:user_id]
  end

  def authorize
    if params['controller'] == 'genome' && params['action'] == 'explore' && request.env['HTTP_USER_AGENT'] =~ /Trident/ && request.env['HTTP_USER_AGENT'] =~ /\.NET CLR/
      logger.info "workaround for genome access via Excel link click. pass thru instead of redirect to login page"
      return
    end

    if session[:user_id].nil? && has_anonymous_access?
      session[:user_id] = "cosmix"
    else
      if !login_user
        logger.debug "login redirect, current url=" + request.env["REQUEST_URI"]
        session[:login_redirect_url] = request.env["REQUEST_URI"]
        redirect_to :controller => 'user', :action => 'login'
        return
      end
    end

    @user = User.get_item_with_name(session[:user_id])

    Thread.current[:user] = @user  #set in thread local var so model can access it

    if BaseUtil.instance.props["modulator.mode"].to_s == "admin" && !user_has_role?("admin")
      set_flash("Sorry, Modulator is in maintenance now and cannot accept your request.")
      logger.error "running in admin mode, reject user #{@user.name}"
      redirect_to :controller => 'user', :action => 'login'
      return
    end

    if !user_has_access_right(@user)
      if @user[:name] == 'cosmix'
        redirect_to '/user/login'
      else
        set_flash "Sorry, the current user doesn't have access permission to this functionality. Please contact admin if you need access."
        redirect_to :root
      end
    end

    # TODO: set debug based on cookie value, set via url param
    @debug = (user_has_role?("dev"))
  end
  
  def set_common_data
    @date = nil
    #TBD: Is this an efficient way to get the maximum date. Do we
    #need this for every call.
    max_min_dates = SearchQualityDaily.get_max_min_dates.first
    @max_date, @min_date = max_min_dates.max_date, max_min_dates.min_date
    @view = params[:view] || 'weekly'
    @date = params[:date] ? Date.strptime(params[:date], '%m-%d-%Y') : @max_date
    @page = params[:page].to_i || 1
    @limit = params[:per_page].to_i || 10
    @sort_by = params[:sort_by]
    @order = params[:order]
  end 

  # output: {year=>, week =>} for multiple year handling
  def get_week_from_date(date)
    date_info = Hash.new
    # ALwasys get teh date for last friday. 
    last_friday_date = date - (date.wday+2)%7
    return Week.get_week_from_date(date)
  end

  # when get previous weeks, it might contain two years. 
  def get_four_weeks_from_date(date)
    # always suppose it has two years    [{week, year}, {week, year}]
    current_week_info = get_week_from_date(date)
    # p current_week_info.to_yaml
    week = current_week_info["week"]
    year = current_week_info["year"]
    weeks = Array.new(2) { Hash.new }
    if week >= 3
      weeks[0]= {"weeks" => (week-3..week).to_a, "year" => year}
    else
      weeks[0] = {"weeks" => (0..week).to_a, "year" => year}
      last_year_total_week = get_dod_week_info(year-1)["total_weeks"]
      weeks[1] = {"weeks" => (last_year_total_week-(3-week-1)..last_year_total_week).to_a, "year" => year-1}
    end
    return weeks
  end
 
  #not really in use 
  def get_date_from_week(week)
    min_date = @min_date.to_datetime.to_i
    max_date = @max_date.to_datetime.to_i
    available_weeks = get_available_weeks()
    selected_week = available_weeks.select {
      |wk| wk[:week].to_i == week.to_i}.first
    return selected_week[:start_date] if selected_week and
      (min_date..max_date).include?(
        selected_week[:start_date].to_datetime.to_i)

    available_weeks.each do |wk|
      next unless (min_date..max_date).include?(
        wk[:start_date].to_datetime.to_i)
      return wk[:start_date] 
    end
    -1
  end
  
  # def get_available_weeks
  #   weeks = Week.available_weeks().map do |curr_week|
  #     start_date = convert_to_dod_date(curr_week[:week], curr_week[:year])
  #     curr_week[:start_date] = start_date
  #     curr_week[:end_date] = start_date + 6.days
  #     curr_week[:fiscal_week] = curr_week[:week] - 3
  #     curr_week
  #   end
  #   return weeks
  # end

  # def available_weeks
  #   respond_to do |format|
  #     format.json {render :json => get_available_weeks}
  #   end 
  # end

  def convert_to_dod_date(week, year)
    first_day_of_jan = get_dod_week_info(year)["start_date"]
    dod_date = first_day_of_jan + (week - 1).weeks
    return dod_date
  end

  # TODO: gonna replace by automatic mapping
  def get_dod_week_info(year)
    week_mapping = Hash.new
    week_mapping["2012"] = {"start_date" => Date.new(2012,1,5), "total_weeks" => 52}
    week_mapping["2013"] = {"start_date" => Date.new(2013,1,5), "total_weeks" => 51}
    week_mapping["2014"] = {"start_date" => Date.new(2014,1,5), "total_weeks" => 52}
    return week_mapping[year.to_s]
  end

  # def convert_to_merchant_week(week, year)
  #   first_week_of_feb = Date.new(year,1,31)
  #   if (first_week_of_feb.wday > 6)
  #     last_sat_of_jan = (first_week_of_feb - first_week_of_feb.wday) + 6
  #   else
  #     last_sat_of_jan = (first_week_of_feb - first_week_of_feb.wday - 7) + 6
  #   end
  #   last_sat_of_jan + (week - 1).weeks
  # end
end
