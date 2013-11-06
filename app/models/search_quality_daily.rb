class SearchQualityDaily < BaseModel
  self.table_name = 'search_quality_daily'

  def self.get_search_relevance_data(
    query_date, page=1, order_col='id', order='asc', limit=10)
    order_str = order_col.nil? ? nil :
      order.nil? ? order_col : order_col + ' ' + order  
    
    self.select(%q{id, query_str, query_date, query_count, query_revenue, 
                search_rev_rank_correlation, query_items, rev_ranks,
                top_rev_items}).where(
                  'query_date = ? ', query_date).order(order_str).page(
                      page).per(limit)
  end
 
  def self.get_search_relevance_data_by_id(id)
    self.select(%q{id, query_str, query_items, top_rev_items}).where(
      'id = ?', id)
  end
  
  def self.get_search_relevance_data_by_word(query_str, query_date)
    select(%q{id, query_str, query_date, query_count, query_revenue,
    search_rev_rank_correlation, query_items, rev_ranks, top_rev_items}).where(
      'query_date = ? and query_str = ?', query_date, query_str)
  end
  
  def self.get_walmart_items(query, cat_id, query_date)
    results = get_search_relevance_data_by_word(query, query_date)
    return results if results.empty?
    
    query_items = results.first['query_items']
    ItemQueryCatMetricsDaily(query, cat_id, query_items.split(','), query_date)
  end
end
