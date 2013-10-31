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
      ["query = ? AND cat_id = ? AND channel = 'TOTAL'", query,
       0]).order("query_date")
  end
  
  def self.get_query_stats_date(query, date)
    selects = %q{unix_timestamp(query_date) * 1000 as query_date, query_count,
      query_pvr, query_atc, query_con, query_revenue}
    QueryCatMetricsDaily.select(selects).where(
      ["query_date = ? AND query = ? AND cat_id = ? AND channel = 'TOTAL'",
       date, query, 0])
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
