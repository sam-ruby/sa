class QueryCountSpcDaily < BaseModel
  self.table_name = 'query_count_spc_daily'

  def self.get_words(
    query, query_date, page=1, order_column='query_score', order='desc', limit=10)
    selects = %q{query query_str, 
    (sqrt(uniq_count)*(100-uniq_con)*z_score)*exp(-pow(days_alarmed-7, 2)/50) as query_score, uniq_count query_count, uniq_con query_con, days_alarmed, days_abovemean, 
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
           %q{signal_flag = 1 and data_date = ? AND cat_id = ? and 
           query = ?}, query_date, 0, query]).order(order_str).page(
             page).per(limit)
      else
        self.select(selects).where([
           %q{signal_flag = 1 and data_date = ? and cat_id = ? and 
           query = ?}, query_date, 0, query]).order(order_str).limit(limit)
      end
    else
      if page > 0 
        self.select(selects).where([
           %q{signal_flag = 1 and data_date = ? AND cat_id = ?},
           query_date, 0]).order(order_str).page(page).per(limit)
      else
        self.select(selects).where([
           %q{signal_flag = 1 and data_date = ? AND cat_id = ?},
           query_date, 0]).order(order_str).limit(limit)
      end
    end
  end
end
