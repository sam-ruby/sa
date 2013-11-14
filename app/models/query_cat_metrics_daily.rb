class QueryCatMetricsDaily < BaseModel
  set_table_name 'query_cat_metrics_daily'

  def self.get_search_words(query_date, cat_id=0, page=1,
                            order_column='id', order='asc', limit=10)
    selects = %q{id, query, channel, query_revenue, query_count, 
      query_pvr, query_atc, query_con, cat_id, query_date}
    if order_column.blank?
      order_str = "sqrt(query_count)*(1-query_con) desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    
   QueryCatMetricsDaily.select(selects).where([
      %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
      channel = "ORGANIC_USER")}, query_date, cat_id]).order(
        order_str).page(page).per(limit)
  end

  def self.get_query_stats(query)
    selects = %q{unix_timestamp(query_date) * 1000 as query_date, query_count,
      query_pvr, query_atc, query_con, query_revenue}
    QueryCatMetricsDaily.select(selects).where(
    [%q{query = ? AND cat_id = ? AND (channel = 'ORGANIC' OR channel = 
    'ORGANIC_USER')}, query, 0]).order("query_date")
  end

  def self.get_query_stats_date(
    query, year, week, query_date, page=1, order_col='search_daily.id',
    order='asc', limit=10)
    
    order_str = order_col.nil? ? 'query_daily.query_count desc' : 
      order.nil? ?  order_col : order_col + ' ' + order  
    
    join_stmt = %Q{as query_daily
    left outer join search_quality_daily as search_daily on
    search_daily.query_date = query_daily.query_date and
    search_daily.query_str = query_daily.query 
    left outer join (select query_str, cat_rate, show_rate, rel_score from
    query_performance where year = #{year} and week = #{week} and
    query_str like '%#{query}%') as qp on
    qp.query_str = query_daily.query} 
    
    selects = %q{search_daily.id, query_daily.query,
    search_daily.search_rev_rank_correlation, query_daily.query_count,
    query_daily.query_pvr, query_daily.query_atc, query_daily.query_con,
    query_daily.query_revenue, (qp.cat_rate * 100) as cat_rate, 
    (qp.show_rate * 100) as show_rate, qp.rel_score}

    joins(join_stmt).select(selects).where(
    %q{query_daily.query_date = ? and query_daily.cat_id = 0 and 
    query_daily.query like ? and (query_daily.channel = "ORGANIC" or 
    query_daily.channel = "ORGANIC_USER")}, query_date, '%'+query+'%').order(
      order_str).page(page).per(limit)
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
