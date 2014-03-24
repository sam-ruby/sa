class TrendingQueriesDaily < BaseModel
  self.table_name = 'trending_queries_daily'
 
  def self.get_trending_words_count(data_date, period)
    count(
      conditions: ['window_in_days = ? and data_date = ?',
                   period, data_date])
  end

  def self.get_trending_words(query, data_date, period=2, page=1,  
                              order_column=nil, order='asc', limit=10)

    sql_stmt = %q{select query, query_revenue_after revenue, 
      query_count_after query_count,
      query_pvr_after  query_pvr,
      query_atc_after query_atc,
      query_con_after query_con,
      query_score rank,
      (query_count_after - query_count_before) query_count_diff
      from trending_queries_daily 
      where window_in_days = ? and data_date = ? %s 
      group by query
      order by %s}
  
    if order_column.nil?
      order_str = "rank desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    
    limit = 2000 if page == 0
    order_limit_str = %Q{ #{order_str} limit #{limit} offset %s}
   
    if query
      query_str = 'and query = ? '
      args = [period, data_date, query]
    else
      query_str = ''
      args = [period, data_date]
    end

    if page > 0 
      order_limit_str %= (page -1) * limit
      find_by_sql([
        sql_stmt % [query_str, order_limit_str], *args]) 
    else
      find_by_sql([
        sql_stmt % [query_str, order_limit_str], *args])
    end
  end
end
