class QueryCatMetricsDaily < BaseModel
  self.table_name = 'query_cat_metrics_daily'

  def self.get_search_words(query, data_date, page=1, 
                            order_column=nil, order='asc', limit=10)
    sql_stmt = %Q{select query, round(query_revenue) revenue, query_count, 
      round(query_pvr*100, 2) query_pvr, round(query_atc*100, 2) query_atc, 
      round(query_con*100, 2) query_con, query_score rank 
      from poor_queries_30days_daily
      where data_date = ? %s 
      order by %s}
  
    if order_column.nil?
      order_str = "rank desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    
    order_limit_str = %Q{ #{order_str} limit #{limit} offset %s}
    limit = 2000 if page == 0
   
    if query
      query_str = 'and query = ? '
      args = [data_date, query]
    else
      query_str = ''
      args = [data_date]
    end

    if page > 0 
      order_limit_str %= (page -1) * limit
      find_by_sql([
        sql_stmt % [query_str, order_limit_str], *args]) 
    else
      find_by_sql([
        sql_stmt % [query_str, order_str], *args])
    end
  end
  
  def self.get_query_stats(query)
    selects = %q{unix_timestamp(data_date) * 1000 as query_date, 
    sum(uniq_count) query_count, 
    round(sum(uniq_pvr)/sum(uniq_count)*100, 2) query_pvr, 
    round(sum(uniq_atc)/sum(uniq_count)*100, 2) query_atc,
    round(sum(uniq_con)/sum(uniq_count)*100, 2) query_con, 
    sum(revenue) query_revenue}

    select(selects).where(
    [%q{query = ? AND cat_id = ? AND (channel = 'ORGANIC_USER' or
     channel = 'ORGANIC_AUTO_COMPLETE') and 
     page_type = 'SEARCH'}, query, 0]).group('data_date').order('data_date')
  end

  def self.get_query_stats_date(
    query, year, week, query_date, page=1, order_col=nil, 
    order='asc', limit=10)
    
    order_str = order_col.nil? ? 'sum(query_daily.uniq_count) desc' : 
      order.nil? ?  order_col : order_col + ' ' + order  
    
    join_stmt = %q{as query_daily
    left outer join search_quality_daily as search_daily on
    search_daily.data_date = query_daily.data_date and
    search_daily.query = query_daily.query} 
    
    selects = %Q{query_daily.query,
    search_daily.search_rev_rank_correlation, 
    sum(query_daily.uniq_count) query_count,
    sum(query_daily.uniq_pvr)/sum(query_daily.uniq_count) query_pvr,
    sum(query_daily.uniq_atc)/sum(query_daily.uniq_count) query_atc,
    sum(query_daily.uniq_con)/sum(query_daily.uniq_count) query_con,
    sum(query_daily.revenue) query_revenue,
    (select assort_overlap * 100 from query_performance_week where year = #{year}
      and week = #{week} and query = query_daily.query
      limit 1) as cat_rate, 
    (select shown_overlap * 100 from query_performance_week where year = #{year}
      and week = #{week} and query = query_daily.query 
      limit 1) as show_rate, 
    (select rel_score from query_performance_week where year = #{year}
      and week = #{week} and query = query_daily.query
      limit 1) as rel_score}

    
    where_conditions = []
    if !query.nil? and query.include?('*')
      query = query.gsub('*', '%')
      where_conditions = sanitize_sql_array([
        %q{query_daily.page_type = 'SEARCH' and 
        query_daily.data_date = '%s' and query_daily.query like '%s' 
        and query_daily.channel = "ORGANIC_USER" and 
        query_daily.cat_id = 0}, query_date, query])
    elsif !query.nil? and !query.empty?
      where_conditions = sanitize_sql_array([
        %q{query_daily.page_type = 'SEARCH' and 
        query_daily.data_date = '%s' and query_daily.query = '%s' 
        and query_daily.channel = "ORGANIC_USER" and 
        query_daily.cat_id = 0}, query_date, query])
    else
      where_conditions = sanitize_sql_array([
        %q{query_daily.page_type = 'SEARCH' and 
        query_daily.data_date = '%s' and  
        query_daily.channel = "ORGANIC_USER" and 
        query_daily.cat_id = 0}, query_date])
    end

    if page > 0
      joins(join_stmt).select(selects).where(where_conditions).group(
        'query_daily.data_date, query_daily.query').order(
        order_str).page(page).per(limit)
    else
      limit = 10000
      joins(join_stmt).select(selects).where(where_conditions).group(
        'query_daily.data_date, query_daily.query').order(
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
