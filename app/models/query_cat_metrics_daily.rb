class QueryCatMetricsDaily < BaseModel
  self.table_name = 'query_cat_metrics_daily'

  def self.get_search_words(
    query, query_date, page=1, order_column=nil, order='asc', limit=10)
    
    selects = %q{query, channel, sum(revenue) revenue, 
      sum(uniq_count) query_count, 
      sum(uniq_pvr)/sum(uniq_count) query_pvr,
      sum(uniq_atc)/sum(uniq_count) query_atc, 
      sum(uniq_con)/sum(uniq_count) query_con, cat_id, data_date}
    
    if order_column.nil?
      order_str = "sqrt(sum(uniq_count))*(1-(sum(uniq_con)/sum(uniq_count))) desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    
    limit = 10000 if page == 0
    
    if query
      if page > 0 
        QueryCatMetricsDaily.select(selects).where([
           %q{data_date = ? AND cat_id = ? AND channel = "ORGANIC_USER" and 
           page_type = 'SEARCH' and query = ?}, query_date, 0, query]).group(
             'query, data_date').order(order_str).page(page).per(limit)
      else
        QueryCatMetricsDaily.select(selects).where([
           %q{data_date = ? AND cat_id = ? AND channel = "ORGANIC_USER" and 
           page_type = 'SEARCH' and query = ?}, query_date, 0, query]).group(
             'query, data_date').order(order_str).limit(limit)
      end
    else
      if page > 0 
        QueryCatMetricsDaily.select(selects).where([
           %q{data_date = ? AND cat_id = ? AND channel = "ORGANIC_USER" and 
           page_type = 'SEARCH'}, query_date, 0]).group(
             'query, data_date').order(order_str).page(page).per(limit)
      else
        QueryCatMetricsDaily.select(selects).where([
           %q{data_date = ? AND cat_id = ? AND channel = "ORGANIC_USER" and
           page_type = 'SEARCH'}, query_date, 0]).group(
             'query, data_date').order(order_str).limit(limit)
      end
    end
  end

  def self.get_query_stats(query)
    selects = %q{unix_timestamp(data_date) * 1000 as query_date, 
    sum(uniq_count) query_count, sum(uniq_pvr)/sum(uniq_count) query_pvr, 
    sum(uniq_atc)/sum(uniq_count) query_atc,
    sum(uniq_con)/sum(uniq_count) query_con, 
    sum(revenue) query_revenue}

    select(selects).where(
    [%q{query = ? AND cat_id = ? AND channel = 'ORGANIC_USER' and 
     page_type = 'SEARCH'}, query, 0]).group('data_date').order('data_date')
  end

  def self.get_query_stats_date(
    query, year, week, query_date, page=1, order_col=nil, order='asc', limit=10)
    
    order_str = order_col.nil? ? 'query_daily.query_count desc' : 
      order.nil? ?  order_col : order_col + ' ' + order  
    
    join_stmt = %q{as query_daily
    left outer join search_quality_daily as search_daily on
    search_daily.query_date = query_daily.query_date and
    search_daily.query_str = query_daily.query} 
    
    selects = %Q{search_daily.id, query_daily.query,
    search_daily.search_rev_rank_correlation, query_daily.query_count,
    query_daily.query_pvr, query_daily.query_atc, query_daily.query_con,
    query_daily.query_revenue,
    (select cat_rate * 100 from query_performance where year = #{year}
      and week = #{week} and query_str = query_daily.query
      limit 1) as cat_rate, 
    (select show_rate * 100 from query_performance where year = #{year}
      and week = #{week} and query_str = query_daily.query 
      limit 1) as show_rate, 
    (select rel_score from query_performance where year = #{year}
      and week = #{week} and query_str = query_daily.query
      limit 1) as rel_score}

    
    where_conditions = []
    if !query.nil? and query.include?('*')
      query = query.gsub('*', '%')
      where_conditions = sanitize_sql_array([
        %q{query_daily.query_date = '%s' and query_daily.query like '%s' 
        and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and 
        query_daily.cat_id = 0}, query_date, query])
    elsif !query.nil? and !query.empty?
      where_conditions = sanitize_sql_array([
        %q{query_daily.query_date = '%s' and query_daily.query = '%s' 
        and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and 
        query_daily.cat_id = 0}, query_date, query])
    else
      where_conditions = sanitize_sql_array([
        %q{query_daily.query_date = '%s'  
        and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and 
        query_daily.cat_id = 0}, query_date])
    end

    if page > 0
      joins(join_stmt).select(selects).where(where_conditions).order(
        order_str).page(page).per(limit)
    else
      limit = 10000
      joins(join_stmt).select(selects).where(where_conditions).order(
        order_str).limit(limit)
    end
  end

  def self.get_week_average(query, date_start, date_end)
    select_cols = %q{sum(query_count) as query_count,
      format(sum(query_count*query_pvr)/sum(query_count), 2) as query_pvr,
      format(sum(query_count*query_atc)/sum(query_count), 2) as query_atc,
      format(sum(query_count*query_con)/sum(query_count), 2) as query_con,
      sum(query_revenue)as query_revenue}
    select(select_cols).where(%q{cat_id=0 and
      (channel="ORGANIC_USER" or channel="ORGANIC") and query=? and
      query_date between ? and ?}, query, date_start, date_end)
  end
end
