class QueryCountSpcDaily < BaseModel
  self.table_name = 'query_count_spc_daily'

  def self.get_words(
    query, query_date, page=1, order_column='query_score', order='desc', limit=10)
    selects = %q{query_str, sqrt(query_count)*(100-query_con)*z_score  as 
    query_score, query_count, query_con, days_alarmed, days_abovemean, 
    z_score}

    if order_column.blank?
      order_str = "query_score desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end
    limit = 10000 if page == 0
    if query and query != ""
      if page > 0 
        self.select(selects).where([
           %q{signal_flag = 1 and query_date = ? AND cat_id = ? and 
           query_str = ?}, query_date, 0, query]).order(order_str).page(
             page).per(limit)
      else
        self.select(selects).where([
           %q{signal_flag = 1 and query_date = ? and cat_id = ? and 
           query_str = ?}, query_date, 0, query]).order(order_str).limit(limit)
      end
    else
      if page > 0 
        self.select(selects).where([
           %q{signal_flag = 1 and query_date = ? AND cat_id = ?},
           query_date, 0]).order(order_str).page(page).per(limit)
      else
        self.select(selects).where([
           %q{signal_flag = 1 and query_date = ? AND cat_id = ?},
           query_date, 0]).order(order_str).limit(limit)
      end
    end
  end
end
