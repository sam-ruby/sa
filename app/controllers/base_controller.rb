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
    if !session[:user_id].nil? and !params[:cat_id]
      user = User.get_item_with_name(session[:user_id])
      @cat_ids = user.get_val(User::DOD_PREF_DEF_CAT_KEY)
    else
      @cat_ids = params[:cat_id]
    end

    @categories = get_categories_map(@cat_ids)
    @cat_id = @categories.last[:c_id]

    @year = @month = @week = @date = nil
    #TBD: Is this an efficient way to get the maximum date. Do we
    #need this for every call.
    @most_recent_date ||= SearchQualityDaily.maximum('query_date')
    
    @view = params[:view] || 'weekly'
    @date = params[:date] ? Date.strptime(params[:date], '%m-%d-%Y') :
      @most_recent_date 
    @year = params[:year].nil? ? PipelineLogWeekly.maximum(:year) :
      params[:year].to_i
    @available_weeks = get_available_weeks
    @week = params[:week] || @available_weeks.first[:week]
    max_min_dates = SearchQualityDaily.get_max_min_dates.first
    @max_date, @min_date = max_min_dates.max_date, max_min_dates.min_date
    
    @page = params[:page].to_i || 1
    @limit = params[:per_page].to_i || 10
    @sort_by = params[:sort_by]
    @order = params[:order]
  end 
  
  def get_categories_map(cat_id_str)
    cat_ids = (cat_id_str || '0').split(/,/).map {|x| x.to_i}
    
    temp_cats = {}
    Category.where(:c_category_id => cat_ids).each do |cat|
      temp_cats[cat.c_category_id] = cat.c_category_name
    end

    cat_ids.unshift(0) unless cat_ids.include?(0)
    temp_cats[0] = t('dashboard.all_departments')

    categories = []
    cat_ids.each do |c_id| 
      categories << {:c_id => c_id, :c_name => temp_cats[c_id]} 
    end
    categories
  end
  
  def get_date_from_week(year, week)
    return Date.new(year, 1, 1) if week == 0
    
    new_year = Date.ordinal(year, 1)
    wday = new_year.wday
    first_sat = 6 - wday + 1
    ordinal = (first_sat > 1 ? week-1 : week) * 7 + first_sat
    Date.ordinal(year, ordinal)
  end
  
  def get_available_weeks
    Week.available_weeks(@year).map do |curr_week|
      start_date = convert_to_dod_week(curr_week[:week], curr_week[:year])
      curr_week[:start_date] = start_date
      curr_week[:end_date] = start_date + 6.days
      curr_week[:fiscal_week] = curr_week[:week] - 3
      curr_week
    end
  end

  def available_weeks
    respond_to do |format|
      format.json {render :json => get_available_weeks}
    end 
  end

  def convert_to_dod_week(week, year)
    first_day_of_jan = Date.new(year,1,5)
    dod_date = first_day_of_jan + (week - 1).weeks
    return dod_date
  end

  def convert_to_merchant_week(week, year)
    first_week_of_feb = Date.new(year,1,31)
    if (first_week_of_feb.wday > 6)
      last_sat_of_jan = (first_week_of_feb - first_week_of_feb.wday) + 6
    else
      last_sat_of_jan = (first_week_of_feb - first_week_of_feb.wday - 7) + 6
    end
    last_sat_of_jan + (week - 1).weeks
  end
end
