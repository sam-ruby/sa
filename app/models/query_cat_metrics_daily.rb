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
end
