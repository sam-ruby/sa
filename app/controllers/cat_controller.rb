require 'date'

class DeptAnalysisController < BaseController
  ITEM_PAGE_SIZE = 32
  
  @@scope_map = {
    :query_revenue => ['revenue_gt', 'revenue_lt'],
    :query_count => ['count_gt', 'count_lt'],
    :query_con => ['con_gt', 'con_lt'],
    :query_atc => ['atc_gt', 'atc_lt'],
    :query_pvr => ['pvr_gt', 'pvr_lt']
  }
  
  before_filter do |controller|
    set_common_data
    break if request.xhr?
    set_expanded_modules
    set_trending_data
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
        CatMetricsDaily.maximum('date')
      end
    
    @view = params[:view] || 'weekly'
    if @view == 'daily'
      @date = params[:date] ? Date.parse(params[:date]) : @most_recent_date 
    end
    
    @weekly_ts = PipelineLogWeekly.maximum(:timestamp).to_i.to_s
    @daily_ts = PipelineLogDaily.maximum(:timestamp).to_i.to_s

    @year = if params[:year].nil? 
      Rails.cache.fetch('max_year' + @weekly_ts, :expires_in => 4.hours) do
        CatMetricsWeek.maximum(:year)
      end
    else
      params[:year].to_i
    end
    @week = params[:week]
    @page = params[:page].to_i || 1
    @sort_column = params[:sort_column]
  end 

  def set_expanded_modules
    params[:module] ||= 'top_queries'
    if params[:action] == 'query' and
      !params[:action].include?('query_items')
      params[:module] << ',query_items'
    elsif params[:action] == 'item' and
      !params[:action].include?('search_terms')
      params[:module] << ',search_terms'
    end
  end

  def set_trending_data
    @all_weeks = PipelineLogWeekly.select("distinct week").order(
      "week DESC").map {|x| x.week}
    @available_weeks = PipelineLogWeekly.select("distinct week").where([
      %q{year = ? AND week NOT IN (SELECT DISTINCT week FROM 
      pipeline_log_weekly WHERE status != 1)}, @year]).order(
        "week DESC").map {|x| x.week}
    @unavailable_weeks = @all_weeks - @available_weeks
    
    @week = params[:week].nil? ?
      (@available_weeks.first) : params[:week].to_i

    get_categories(@view, @cat_id, @year, @month, @week, @date)
    @top_trending_items = get_top_trending_items(@cat_id, @year, @week)
    @top50 = get_query_cat_top50(@view, @cat_id, 0, @year, @month, @week, @date)
    @top_selling = get_top_sellers(@year, @week, @cat_id)
    @sort_column = params[:sort_column]
    #handle kaminari bug where desc is appended to sort_column
    if !@sort_column.blank? and @sort_column.end_with?(' desc')
      @sort_column = @sort_column.slice(0, @sort_column.length - 5)
    end
    @dir = params[:dir].blank? ? 0 : params[:dir].to_i
    get_queries(
      @view, @cat_id, @page, @year, @month, @week, @date, @sort_column, @dir)
  end

  def index
    paging = request.xhr?
    if !paging
      @title = I18n.t 'dashboard.departmental_analysis'
      #@crumbs.unshift(0, I18n.t('dashboard.all_departments'))
      @chart_data = get_chart_data(@view, @cat_id, @year, @month, @week, @date)

    elsif paging
      #handle kaminari bug where desc is appended to sort_column
      if !@sort_column.blank? and @sort_column.end_with?(' desc')
        @sort_column = @sort_column.slice(0, @sort_column.length - 5)
      end
      @dir = params[:dir].blank? ? 0 : params[:dir].to_i
      get_queries(
        @view, @cat_id, @page, @year, @month, @week, @date, @sort_column, @dir)
      render :paging, :locals=>{:mod_id=>:bad_queries} 
    end
  end
  
  def query
    @title = t 'dashboard.query_performance'
    @query = params[:query]

    @query_data = @items = []
    if !@query.blank?
      item_selects = %q{item.item_id, item.item_revenue, item.shown_count,
        item.item_con, item.item_atc, item.item_pvr, total.revenue}
      case @view
        when 'daily'
          selects = %q{query_date, query_count, query_pvr, query_atc, 
            query_con, query_revenue}
          @query_data = QueryCatMetricsDaily.select(selects).where(
            ["query = ? AND cat_id = ? AND channel = 'TOTAL'", @query,
             0]).order("query_date")
          
          @date = params[:date].nil? ?
            ItemQueryCatMetricsDaily.maximum('query_date') :
              Date.parse(params[:date])
        else
          selects = 'year, week, query_count, query_pvr, query_atc, ' +
            'query_con, query_revenue'
          @query_data = QueryCatMetricsWeek.select(selects).where(
            ["query = ? AND cat_id = ? AND channel = 'TOTAL' AND week IN (?)",
             @query, 0, @available_weeks]).order("year, week")
          @query_data.each do |obj| 
            obj['query_date'] =
              get_date_from_week(obj['year'].to_i, obj['week'].to_i)
          end
      end
      @amazon_comparison_items = get_amazon_comparison_items(
        @query, @date, @year, @week) || []
      @items = get_query_items(@query, 0, @date, @year, @week)
      
      @log = true
      @query_data.each do |point|
        ['query_pvr', 'query_atc', 'query_con'].each do |field|
          if point[field] == 0
            @log = false
            break
          end
        end
        break unless @log
      end
    end
  end
  
  def item
    @id = params[:id] ||params[:item_id]
    @query = params[:query]

    if @id.blank?
      render :inline => "Item ID must be supplied."
      return
    end

    @title = t 'dashboard.item_performance'

    page = params[:page].nil? ? 1 : params[:page].to_i
    item_selects = %q{SUM(item.item_revenue) AS item_revenue,
      SUM(item.shown_count * item.item_con)/SUM(item.shown_count) AS item_con,
      SUM(item.shown_count * item.item_atc)/SUM(item.shown_count) AS item_atc, 
      SUM(item.shown_count * item.item_pvr)/SUM(item.shown_count) AS item_pvr,
      total.revenue AS revenue}
    
    case @view
      when 'daily'
        @date = params[:date].nil? ?
          ItemQueryCatMetricsDaily.maximum('query_date') :
          Date.parse(params[:date])
        selects = %q{query, item_revenue, shown_count, item_con, item_atc,
          item_pvr}
        @query_words = ItemQueryCatMetricsDaily.select(selects).where(
          [%q{query_date = ? and item_id = ? AND channel = 'TOTAL' AND
            cat_id = 0}, @date, @id]).order(
              'item_revenue DESC, shown_count DESC').page(page)
        
        join_stmt = %q{AS a LEFT OUTER JOIN item_cat_total_revenue_daily b ON
            a.query_date = b.date AND a.item_id = b.item AND a.cat_id = 
            b.cat_id}
        chart_selects = %q{a.query_date, b.revenue AS site_revenue, 
          SUM(a.item_revenue) AS search_revenue,
          SUM(a.shown_count) as sum_count, SUM(a.shown_count*a.item_con)/
          SUM(a.shown_count) as avg_con, SUM(a.shown_count*a.item_atc)/SUM(
          a.shown_count) AS avg_atc,
          SUM(a.shown_count*a.item_pvr)/SUM(a.shown_count)
          as avg_pvr}
        @chart_data = ItemQueryCatMetricsDaily.joins(join_stmt).select(
          chart_selects).where(
          %q{a.item_id = ? AND a.channel = 'TOTAL' AND a.cat_id = 0},
          @id).group('a.query_date').order('a.query_date')
      else
        selects = %q{query, item_revenue, shown_count, item_con, item_atc,
          item_pvr}
        @query_words = ItemQueryCatMetricsWeek.select(selects).where(
          [%q{year = ? and week = ? and item_id = ? AND channel = 'TOTAL'
          AND cat_id = 0}, @year, @week, @id]).order(
            %q{item_revenue DESC, shown_count DESC})
        join_stmt = %q{AS a LEFT OUTER JOIN item_cat_total_revenue_week b ON
          a.year = b.year AND a.week = b.week AND a.item_id = b.item AND
          a.cat_id = b.cat_id}
        chart_selects = %q{a.year, a.week, sum(a.item_revenue) as 
          search_revenue, sum(a.shown_count) as sum_count, 
          sum(a.shown_count*a.item_con)/
          sum(a.shown_count) as avg_con, sum(a.shown_count*a.item_atc)/
          sum(a.shown_count) as avg_atc, sum(a.shown_count*a.item_pvr)/
          sum(a.shown_count) as avg_pvr, b.revenue as site_revenue}
        @chart_data = ItemQueryCatMetricsWeek.joins(join_stmt).select(
          chart_selects).where(%q{a.item_id = ? AND a.channel = 'TOTAL' AND
          a.cat_id = 0 AND a.week in (?)}, @id, @available_weeks).group(
            'a.year, a.week').order('a.year, a.week')
        @chart_data.each do |obj| 
          obj['query_date'] = get_date_from_week(
            obj['year'].to_i, obj['week'].to_i)
        end
    end
    @items = get_query_items(@query, 0, @date, @year, @week)

    @log = true
    @chart_data.each do |point|
      ['avg_pvr', 'avg_atc', 'avg_con'].each do |field|
        if point[field] == 0
          @log = false
          break;
        end
      end
      break unless @log
    end
  end

  private
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
  
  def get_queries(view, cat_id, page, year, month, week, date, sort_column, dir)
    selects = %q{query, channel, query_revenue, query_count, query_pvr,
      query_atc, query_con}
    
    fields = [:query_revenue, :query_count, :query_con, :query_atc, :query_pvr]
    map = {}
    if params[:filter]
      fields.each do |field|
        vals = [String.new, String.new]
        (0..1).each do |index|
          vals[index] =
            params[:filter][field][index.to_s] if !params[:filter][field].nil?
        end
        map[field] = vals
      end
    end
    
    if sort_column.blank?
      order = "sqrt(query_count)*(1-query_con) desc"
    else
      order = sort_column
      order << ' desc' if dir == 1
    end
    
    case view
    when 'daily'
      @queries = QueryCatMetricsDaily.select(selects).where([
      %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
      channel = "ORGANIC_USER")}, date, cat_id]).order(order).page(page)
    when 'weekly'
      @queries = QueryCatMetricsWeek.select(selects).where(
      [%q{year = ? AND week = ? AND cat_id = ? AND query_count > 70 
       AND (channel = "ORGANIC" OR channel = "ORGANIC_USER")}, year,
       week, cat_id]).order(order).page(page)
    end
  end
  
  def get_query_cat_top50(view, cat_id, page, year, month, week, date)
    selects = %q{query_str, query_rank, query_rev_correl, query_revenue,
      query_count, query_pvr, query_atc, query_con}
    join_term = %q{LEFT OUTER JOIN query_cat_metrics_week ON 
      check_year = year and check_week = week and channel = 'TOTAL' and 
      query_cat_metrics_week.cat_id = 0 and query_str = query}
    Rails.cache.fetch(
      "trending_queries_#{year}_#{week}_#{cat_id}" + @weekly_ts,
      :expires_in=>4.hours) do
      QueryCatTop50Week.joins(join_term).select(
          selects).where([%q{query_rank > 0 and check_year = ? AND check_week 
          = ? AND query_cat_top50_week.cat_id = ?},
          year, week, cat_id]).order('query_rank').to_a
    end
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

  # Based on the cat_id string passed in, set the category names in the order
  # for Bread crumbs to display accordingly.
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

  def get_top_trending_items(cat_id, year, week)
    join_str = 'AS item LEFT OUTER JOIN all_item_attrs AS item_attrs ON ' +
      'item.item_id = item_attrs.item_id'
    Rails.cache.fetch(
      "trending_items_#{year}_#{week}_#{cat_id}" + @weekly_ts,
      :expires_in=>4.hours) do
        ItemCatTop50Week.joins(join_str).where(
          %q{item.check_week = ? and item.check_year = ? and item.cat_id = ?},
          week, year, cat_id).select(%q{item.item_rank, item.item_id, 
          item.rev_thisweek, item.rev_lastweek, item_attrs.title, 
          item_attrs.image_url}).order('item.item_rank ASC').to_a
    end
  end

  def get_top_sellers(year, week, cat_id)
    Rails.cache.fetch(
      "top_sellers_#{year}_#{week}_#{cat_id}" + @weekly_ts,
      :expires_in => 4.hours) do 
        ItemCatTotalRevenueWeek.joins(
        %q{AS total INNER JOIN all_item_attrs AS item_attrs ON 
        total.item = item_attrs.item_id}).select(%q{total.item as item_id,
        total.revenue as site_revenue, item_attrs.title, 
        item_attrs.image_url}).where(%q{total.year = ? and total.week = ? and
        total.cat_id = ? }, year, week, cat_id).order(
          'total.revenue DESC').limit(50).to_a
    end
  end

  def get_amazon_comparison_items(query_str, date=nil, year=nil, week=nil)
    if @view == 'weekly'
      amazon_comparison_items = URLMapping.select(
        %q{distinct item_id,idd, name, brand, position,
        amazon_scrape_weekly.name, brand, imgurl as img_url, 
        amazon_scrape_weekly.url, newprice}).joins(%q{RIGHT OUTER JOIN 
        amazon_scrape_weekly ON url_mapping.retailer_id = 
        amazon_scrape_weekly.idd}).where(%q{query_str = ? and check_week = 
        ?},query_str, week) 
        
        walmart_items = Array.new
        amazon_comparison_items.each do |curr_row|
          if curr_row.item_id != nil
            walmart_items << curr_row.item_id
          end
        end

        walmart_prices = AllItemAttrs.select(
          'item_id, curr_item_price').where(:item_id => walmart_items)

        amazon_comparison_items.each do |curr_row|
          if curr_row.item_id != nil
            walmart_prices.each do |curr_price|
              if curr_row.item_id.to_i == curr_price.item_id.to_i
                curr_row.walmart_price = curr_price.curr_item_price
              end
            end
          end
        end
      amazon_comparison_items;
    elsif @view == 'daily'
      []
    end
  end

  def get_query_items(query, cat_id, date=nil, year=nil, week=nil)
    if @view == 'weekly'
      item_selects = %q{item.item_id, item.item_revenue, item.shown_count,
        item.item_con, item.item_atc, item.item_pvr,
        total.revenue as site_revenue,
        item_attrs.title, item_attrs.image_url}
      join_stmt = %q{AS item LEFT OUTER JOIN item_cat_total_revenue_week AS 
        total ON total.year = item.year AND total.week = item.week AND 
        total.cat_id = item.cat_id AND total.item = item.item_id  
        LEFT OUTER JOIN all_item_attrs AS 
        item_attrs ON item.item_id = item_attrs.item_id}
      
      ItemQueryCatMetricsWeek.joins(join_stmt).select(item_selects).where(
        %q{item.year = ? AND item.week = ? AND item.query = ? AND 
        item.cat_id = ? AND item.channel = "TOTAL"}, year, week, query,
        cat_id).order('item_revenue DESC, shown_count DESC').limit(32)
    elsif @view == 'daily'
      item_selects = %q{item.item_id, item.item_revenue, item.shown_count,
        item.item_con, item.item_atc, item.item_pvr, total.revenue as
        site_revenue, item_attrs.title, item_attrs.image_url}
      join_stmt = %q{AS item LEFT OUTER JOIN item_cat_total_revenue_daily AS 
        total ON total.date = item.query_date AND total.cat_id = item.cat_id AND
        total.item = item.item_id 
        LEFT OUTER JOIN all_item_attrs AS item_attrs ON 
        item.item_id = item_attrs.item_id}
      ItemQueryCatMetricsDaily.joins(join_stmt).select(item_selects).where(
        %q{item.query_date = ? AND item.query = ? AND item.cat_id = ? AND 
          item.channel = "TOTAL"}, date, query, cat_id).order(
            'item_revenue DESC, shown_count DESC').limit(32)
    end
  end
end
