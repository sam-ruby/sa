class QueryCatMetricsDaily < BaseModel
  self.table_name = 'query_cat_metrics_daily'

  def self.get_search_words(
    query_date, page=1, order_column='id', order='asc', limit=10)
    
    selects = %q{id, query, channel, query_revenue, query_count, 
      query_pvr, query_atc, query_con, cat_id, query_date}
    
    if order_column.blank?
      order_str = "sqrt(query_count)*(1-query_con) desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end

    if page > 0 
      QueryCatMetricsDaily.select(selects).where([
         %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
         channel = "ORGANIC_USER")}, query_date, 0]).order(
           order_str).page(page).per(limit)
    else
      limit = 10000
      QueryCatMetricsDaily.select(selects).where([
         %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
         channel = "ORGANIC_USER")}, query_date, 0]).order(
           order_str).limit(limit)
    end
  end

  def self.get_query_stats(query)
    selects = %q{unix_timestamp(query_date) * 1000 as query_date, query_count,
      query_pvr, query_atc, query_con, query_revenue}
    QueryCatMetricsDaily.select(selects).where(
    [%q{query = ? AND cat_id = ? AND (channel = 'ORGANIC' OR channel = 
    'ORGANIC_USER')}, query, 0]).order("query_date")
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
