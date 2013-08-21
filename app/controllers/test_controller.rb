class TestController < BaseController
  include HomeHelper

  before_filter :set_common_data

  def index
  end

  def cat
    data_type = params[:data_type] || 'cat_metrics'
    if data_type == 'cat_metrics'
      get_chart_data(@view, @cat_id, @year, @month, @week, @date)
      
      if @chart_data.nil? or @chart_data.empty?
        render :nothing => true, :status => 200
      else
        render :json => {:props => Props, :chart_data => @chart_data,
                         :chart_title=>@categories.last[:c_name]}.to_json
      end
    else
      get_categories(@view, @cat_id, @year, @month, @week, @date)
      if @sorted.nil?
        render :nothing=>true, :status => 200
      else
        render :partial => 'sub_categories'
      end
    end
  end
  
 
  def get_chart_data(view, cat_id, year, month, week, date)
    @log_cat = true
    case view
      when 'daily'
        condition = ["cat_id = ? AND channel = 'TOTAL'", cat_id]
        @chart_data = Rails.cache.fetch(
          "cat_metrics_chart_daily_#{date}_#{cat_id}" + @daily_ts,
          :expires_in => 4.hours) do
            CatMetricsDaily.find(
            :all, :select => %q{date, cat_revenue, cat_count, cat_pvr, 
            cat_atc, cat_con}, :order => 'date', :conditions => condition)
          end
      when 'weekly'
        condition = ["cat_id = ? AND channel = 'TOTAL' AND week in (?)",
                     cat_id, @available_weeks]
        @chart_data = Rails.cache.fetch(
          "cat_metrics_chart_weekly_#{year}_#{week}_#{cat_id}" + @weekly_ts,
          :expires_in => 4.hours) do
            CatMetricsWeek.find(
            :all, :select => %q{year, week, cat_revenue, cat_count, cat_pvr, 
            cat_atc, cat_con}, :order => 'year, week', :conditions => condition)
        end
    end

    catch :stop_iteration do
      @chart_data.each do |obj| 
        obj['date'] = get_date_from_week(
          obj['year'].to_i, obj['week'].to_i) if view == 'weekly'
        if @log_cat
          ['cat_pvr', 'cat_atc', 'cat_con'].each do |field|
            if obj[field] == 0
               @log_cat = false
               throw :stop_iteration if view == 'daily'
               break
            end
          end
        end
      end
    end
  end
  
  def get_categories(view, cat_id, year, month, week, date)
    selects = %q{categories.c_category_name, cat.cat_id, cat.channel,
      cat.cat_revenue, cat.cat_count, cat.cat_pvr, cat.cat_atc, cat.cat_con,
      total.revenue}
    
    case view
      when 'daily' 
        join_stmt = %q{AS cat INNER JOIN categories ON 
          categories.c_category_id = cat.cat_id LEFT OUTER JOIN 
          cat_total_revenue_daily AS total ON total.date = 
          cat.date AND total.cat = cat.cat_id}
        @cats = Rails.cache.fetch(
          "cat_metrics_#{date}" + @daily_ts, :expires_in => 4.hours) do
            CatMetricsDaily.joins(join_stmt).select(selects).where(
              'cat.date = ? AND categories.p_category_id = ?', date, cat_id)
          end
      when 'weekly' 
        join_stmt = %q{AS cat INNER JOIN categories ON
        categories.c_category_id = cat.cat_id LEFT OUTER JOIN 
        cat_total_revenue_week AS total ON total.year = cat.year AND 
        total.week = cat.week AND total.cat = cat.cat_id}
        @cats = Rails.cache.fetch(
          "cat_metrics_#{year}_#{week}_#{cat_id}" + @weekly_ts,
          :expires_in => 4.hours) do
              CatMetricsWeek.joins(join_stmt).select(
              selects).where(%q{cat.year = ? AND cat.week = ? AND 
              categories.p_category_id = ?}, year, week, cat_id).sort do
                |a,b| [a["cat_id"], b["cat_revenue"]] <=>[b["cat_id"],
                                                      a["cat_revenue"]]
                end
          end
    end
    if !@cats.empty?
      @sorted = []
      curr_cat_id = ""
      start = row_span = total = total_index = 0
      @cats.each_index do |index|
        row = @cats[index]
        if row["cat_id"] != curr_cat_id
          @sorted.push({:start => start, :row_span => row_span, :total => total,
                        :total_index => total_index}) if !curr_cat_id.blank?
          
          curr_cat_id = row["cat_id"]
          start = index
          row_span = 1
          total = 0
        else
          row_span += 1
        end
        
        # Total can be the first row when cat_id changes
        if row["channel"] == "TOTAL"
          total = row["cat_revenue"]
          total_index = index
        end
      end
      
      @sorted.push({:start => start, :row_span => row_span, :total => total,
                    :total_index => total_index}) if !@cats.empty?
      #last category
      @sorted.sort! {|a,b| b[:total] <=> a[:total]}
    end    
  end

end
