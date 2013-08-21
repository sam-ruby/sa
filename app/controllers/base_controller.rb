class BaseController < ApplicationController

  layout 'test'

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
    @most_recent_date ||= Rails.cache.fetch(
      'max_date', :expires_in => 4.hours) do 
        PipelineLogDaily.maximum('date')
      end
    
    @view = params[:view] || 'weekly'
    @date = params[:date] ? Date.parse(params[:date]) : @most_recent_date 
    
    @weekly_ts = PipelineLogWeekly.maximum(:timestamp).to_i.to_s
    @daily_ts = PipelineLogDaily.maximum(:timestamp).to_i.to_s

    @year = if params[:year].nil? 
      Rails.cache.fetch('max_year' + @weekly_ts, :expires_in => 4.hours) do
        PipelineLogWeekly.maximum(:year)
      end
    else
      params[:year].to_i
    end
    @page = params[:page].to_i || 1
    @limit = params[:per_page].to_i || 10
    @sort_by = params[:sort_by]
    @order = params[:order]
    
    @all_weeks = Rails.cache.fetch('all_weeks' + @weekly_ts,
                                   :expires_in => 4.hours) do
      PipelineLogWeekly.select("distinct week").order(
      "week DESC").map {|x| x.week}
    end

    @available_weeks = Rails.cache.fetch('available_weeks' + @weekly_ts,
                                         :expires_in => 4.hours) do
      PipelineLogWeekly.select("distinct week").where([
      %q{year = ? AND week NOT IN (SELECT DISTINCT week FROM 
      pipeline_log_weekly WHERE status != 1)}, @year]).order(
        "week DESC").map {|x| x.week}
    end
    @unavailable_weeks = @all_weeks - @available_weeks
    @week = params[:week].nil? ?
      (@available_weeks.first) : params[:week].to_i
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
  
  def most_recent_week
    @most_recent_date ||= CatMetricsDaily.maximum(:date)
    CatMetricsWeek.where('year = ?', @most_recent_date.year).maximum(:week)
  end
 
end
