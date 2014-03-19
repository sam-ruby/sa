class TrendingQueriesDaily < BaseModel
  self.table_name = 'trending_queries_daily'
 
  def self.get_trending_words_count(data_date, period)
    start_date = data_date - period.days
    count(
      select: 'query',
      distinct: true,
      conditions: ['window_in_days = 1 and data_date >= ? and data_date <= ?',
                   start_date, data_date])
  end

  def self.get_trending_words(query, data_date, period=2, page=1,  
                              order_column=nil, order='asc', limit=10)

    start_date = data_date - (period - 2).days
    sql_stmt = %q{select query, sum(query_revenue_after) revenue, 
      sum(query_count_after) query_count,
      round(sum(query_pvr_after)/sum(query_count_after)*100, 2)  query_pvr,
      round(sum(query_atc_after)/sum(query_count_after)*100, 2) query_atc,
      round(sum(query_con_after)/sum(query_count_after)*100, 2) query_con,
      avg(query_score) rank 
      from trending_queries_daily 
      where window_in_days = 1 and data_date >= ? and  data_date <= ? %s 
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
      args = [start_date, data_date, query]
    else
      query_str = ''
      args = [start_date, data_date]
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
end
