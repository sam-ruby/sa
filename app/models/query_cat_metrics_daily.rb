class QueryCatMetricsDaily < BaseModel
  self.table_name = 'query_cat_metrics_daily'

  def self.get_search_words(
    query, query_date, page=1, order_column='id', order='asc', limit=10)
    
    selects = %q{id, query, channel, query_revenue, query_count, 
      query_pvr, query_atc, query_con, cat_id, query_date}
    
    if order_column.blank?
      order_str = "sqrt(query_count)*(1-query_con) desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    
    limit = 10000 if page == 0
    
    if query
      if page > 0 
        QueryCatMetricsDaily.select(selects).where([
           %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
           channel = "ORGANIC_USER") and query = ?},
           query_date, 0, query]).order(order_str).page(page).per(limit)
      else
        QueryCatMetricsDaily.select(selects).where([
           %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
           channel = "ORGANIC_USER") and query = ?},
           query_date, 0, query]).order(order_str).limit(limit)
      end
    else
      if page > 0 
        QueryCatMetricsDaily.select(selects).where([
           %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
           channel = "ORGANIC_USER")}, query_date, 0]).order(
             order_str).page(page).per(limit)
      else
        QueryCatMetricsDaily.select(selects).where([
           %q{query_date = ? AND cat_id = ? AND (channel = "ORGANIC" OR 
           channel = "ORGANIC_USER")}, query_date, 0]).order(
             order_str).limit(limit)
      end
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

  def self.get_cvr_dropped_query(before_start_date,before_end_date,after_start_date,after_end_date,sum_count,page=1, limit=10)
    sqlStatement=
    'select query, con_before, con_after, diff, rev_before, rev_after from 
  (select b.query as query, b.con as con_before, d.con as con_after, b.con-d.con as diff, b.revenue as rev_before, d.revenue as rev_after from 
    (select query, con, revenue from (
      select 
        query, 
        sum(query_count) as sum_count, 
        sum(query_count*query_con)/sum(query_count) as con, 
        sum(query_revenue) as revenue 
       from query_cat_metrics_daily 
       where query_date in (?) and 
       cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC") group by query having sum_count >= ? and con>0.02
     )a 
    )b 
    inner join 
    (select query,con, revenue from (
       select 
         query, 
         sum(query_count) as sum_count, 
         sum(query_count*query_con)/sum(query_count) as con, 
         sum(query_revenue) as revenue from query_cat_metrics_daily 
      where 
        query_date in (?) and cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC") group by query having sum_count >=?
     )c 
    )d 

    on b.query=d.query)f where diff>0.02
order by diff desc;'

  p 'sum_count', sum_count
  # date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
  # date_months.map {|d| d.strftime "%d/%m/%Y" }
    before_date_arr=(before_start_date..before_end_date).map{ |date| date.strftime("%Y-%m-%d")}
    after_date_arr=(after_start_date..after_end_date).map{ |date| date.strftime("%Y-%m-%d")}

    # before_date_arr=["2013-09-20", "2013-09-21", "2013-09-22", "2013-09-23", "2013-09-24", "2013-09-25", "2013-09-26"]
    # after_date_arr=["2013-09-27", "2013-09-28", "2013-09-29", "2013-09-30", "2013-10-01", "2013-10-02", "2013-10-03"]

    result_data = find_by_sql([sqlStatement,before_date_arr, sum_count, after_date_arr, sum_count]) 

 
   
  end
end
