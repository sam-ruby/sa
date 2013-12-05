class SearchQualityDaily < BaseModel
  self.table_name = 'search_quality_daily'
  def self.get_search_relevance_data(
    query_date, page=1, order_col='id', order='asc', limit=10)
    order_str = order_col.nil? ? 'query_count desc, search_rev_rank_correlation asc' : order.nil? ? order_col : order_col + ' ' + order  
    
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
    search_rev_rank_correlation, 32_query_items, rev_ranks, top_rev_items}
    ).where('query_date = ? and query_str = ?', query_date, query_str)
  end
  
  def self.get_walmart_items(query, query_date)
    results = get_search_relevance_data_by_word(query, query_date)
    return results if results.empty?
    query_items = results.first['32_query_items'].split(',')
    results = AllItemAttrs.get_items(query, query_items, query_date)
    query_items.map {|item_id| results.select do|item|
      item.item_id == item_id
    end.first }
  end


  def self.get_max_min_dates
    select(%q{max(query_date) as max_date, min(query_date) as min_date})
  end

  def self.get_query_stats(
    query, year, week, query_date, 
    page=1, order_col=nil, order='asc', limit=10)
    
    order_str = order_col.nil? ? 'rank_metric desc' : 
      order.nil? ? order_col : order_col + ' ' + order  
    
    join_stmt = %Q{as search_daily join query_cat_metrics_daily as query_daily 
    on search_daily.query_date = query_daily.query_date and
    search_daily.query_str = query_daily.query}

    selects = %Q{search_daily.id, search_daily.query_str,
    search_daily.search_rev_rank_correlation, query_daily.query_count,
    query_daily.query_pvr, query_daily.query_atc, query_daily.query_con,
    query_daily.query_revenue, 
    (select cat_rate * 100 from query_performance where year = #{year}
      and week = #{week} and query_str = search_daily.query_str 
      limit 1) as cat_rate, 
    (select show_rate * 100 from query_performance where year = #{year}
      and week = #{week} and query_str = search_daily.query_str 
      limit 1) as show_rate, 
    (select rel_score from query_performance where year = #{year}
      and week = #{week} and query_str = search_daily.query_str
      limit 1) as rel_score,    
    (select SQRT(query_daily.query_count)*(1-query_daily.query_con)*(cat_rate/100-show_rate/100)) 
    as rank_metric}

    #rank_metric_caltulation:sqrt(Qquerycout)(1-conversionrate)(catoverlap- show rate);
  
    where_conditions = []
    if !query.nil? and query.include?('*')
      query = query.gsub('*', '%')
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
        '%s' and search_daily.query_str like '%s'}, query_date, query])
    elsif !query.nil? and !query.empty?
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
        '%s' and search_daily.query_str = '%s'}, query_date, query])
    else
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
        query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
        '%s'}, query_date])
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

  # get item comparisons based on a query from cvr_dropped_query table, small set, client side pagination
  def self.get_cvr_dropped_query_item_comparisons(query, before_start_date,before_end_date,after_start_date,after_end_date)
    # result: query_items: "21630182,19423472,4764723,14237607,4764726,10992861, there is no related rank for that sequence. 
    # search_quality_daily
    item_ids_two_week_before = find_by_sql(['select query_items from search_quality_daily where query_str="sewing machine" and query_date=(select max(query_date) from search_quality_daily where query_str="sewing machine" and query_date>"2013-09-12" and query_date<="2013-09-26")'])
    item_ids_two_week_after = find_by_sql(['select query_items from search_quality_daily where query_str="sewing machine" and query_date=(select max(query_date) from search_quality_daily where query_str="sewing machine" and query_date>"2013-09-26" and query_date<="2013-10-10")'])
    

    # p 'item_ids_two_week_before_arr', item_ids_two_week_before[0]['query_items']
    # p 'item_ids_two_week_after_arr', item_ids_two_week_after[0]['query_items']

    item_ids_two_week_before_arr = item_ids_two_week_before[0]['query_items'].split(",")
    item_ids_two_week_after_arr = item_ids_two_week_after[0]['query_items'].split(",")

    p 'item_ids_two_week_before_arr', item_ids_two_week_before_arr
    p 'item_ids_two_week_after_arr', item_ids_two_week_after_arr
    
    #find the items 
    item_before_arr= find_by_sql(['select item_id, title, image_url, seller_id FROM all_item_attrs where item_id in (?)', item_ids_two_week_before_arr])
    item_after_arr= find_by_sql(['select item_id, title, image_url, seller_id FROM all_item_attrs where item_id in (?)', item_ids_two_week_after_arr])

    #since this is a small list, it is ok to process the merge



    p "items_two_week_before, ", item_before_arr.to_yaml
    p "items_two_week_after, ", item_after_arr.to_yaml
  end
end
