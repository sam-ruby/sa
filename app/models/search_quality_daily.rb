class SearchQualityDaily < BaseModel
  self.table_name = 'search_quality_daily'
  def self.get_search_relevance_data(
    query_date, page=1, order_col='uniq_count', order='asc', limit=10)
    
    order_str = order_col.nil? ? 
      'uniq_count desc, search_rev_rank_correlation asc' : 
      order.nil? ? order_col : order_col + ' ' + order  
    
    select(%q{query, data_date, uniq_count, revenue,
    search_rev_rank_correlation, query_items, rev_ranks,
           top_rev_items}).where(
             'data_date = ? ', query_date).order(order_str).page(
               page).per(limit)
  end
 
  def self.get_search_relevance_data_by_id(id)
    self.select(%q{id, query, query_items, top_rev_items}).where(
      'id = ?', id)
  end

  def self.get_search_relevance_data_by_word(query_str, query_date)
    select(%q{query, data_date, uniq_count, revenue,
    search_rev_rank_correlation, 32_query_items, rev_ranks, top_rev_items}
    ).where('data_date = ? and query = ?', query_date, query_str)
  end
  
  def self.get_walmart_items_daily(query, query_date)
    results = get_search_relevance_data_by_word(query, query_date)
    return results if results.empty?
    query_items = results.first['32_query_items'].split(',')
    results = AllItemAttrs.get_items(query, query_items, query_date)
    query_items.map {|item_id| results.select do|item|
      item.item_id == item_id
    end.first
    }
  end


  def self.get_max_min_dates
    select(%q{max(data_date) as max_date, min(data_date) as min_date})
  end

  def self.get_query_stats(
    query, year, week, query_date, 
    page=1,  limit=10, order_col=nil, order='asc')
    
    order_str = order_col.nil? ? 'order by rank_metric desc' : 
      order.nil? ? 'order by ' + order_col : %Q{order by #{order_col} #{order}}
    offset = (page - 1) * 10
    order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}

    sql_stmt = %Q{select in_tab_a.*, 
      (in_tab_a.query_con/in_tab_a.query_count)*100 query_con, 
      (select SQRT(in_tab_a.query_count)*(100-(in_tab_a.query_con/in_tab_a.query_count)
      )*(in_tab_a.cat_rate/100-in_tab_a.show_rate/100)) rank_metric 
      from 
        (select
        a.query,
        a.search_rev_rank_correlation, 
        sum(b.uniq_count) as query_count, 
        sum(b.uniq_con) as query_con, 
        sum(b.revenue) revenue, 
        (c.assort_overlap * 100) cat_rate, 
        (c.shown_overlap * 100) show_rate, 
        c.rel_score 
        from 
          (SELECT query, search_rev_rank_correlation, data_date FROM 
          search_quality_daily WHERE data_date = ? %s) a,
          query_cat_metrics_daily b,
          query_performance_week c 
          where 
          b.cat_id = 0 and b.page_type='SEARCH' and b.channel = 'ORGANIC_USER' 
          and b.data_date = a.data_date and b.query = a.query and 
          c.year = ? and c.week = ? and c.query = a.query 
          group by b.query, b.cat_id, b.channel) in_tab_a #{order_limit_str}} 

    if query.nil? or query.empty? 
      return find_by_sql([sql_stmt % '', query_date, year, week])
    end  
    
    my_match= /^EXACT_WORD=(.*)ALL_WORD=(.*)ANY_WORD=(.*)NONE_WORD=(.*)$/.match(query)  

    if my_match.nil?  
      return find_by_sql(
        [sql_stmt % "and query = '#{query}'", query_date, year, week])
    end

    exact_word = my_match[1]
    if exact_word!= ''
      return find_by_sql(
        [sql_stmt % "and query = '#{exact_word}'", query_date, year, week])
    end

    # if it is not exact world need to generate that condition string
    all_word = my_match[2]
    any_word = my_match[3]
    none_word = my_match[4]

    like_str = ''
    # like 'ipad% mini%'
    if all_word!= ''
      sub_match = all_word.split(/\s+/)
      sub_match.collect!{|x|
        x = '%'+ x + '%'
      }
      like_str= like_str +'and query like'  + '\'' + 
        sub_match.join(' ') + '\''
    end

    #REGEXP 'ipad|mini'
    if any_word!= ''
      sub_match = any_word.split(/\s+/) 

      like_str = like_str + ' and query REGEXP' +  '\'' + 
        sub_match.join("|") + '\''
    end

    #NOT REGEXP 'heater|desk'
    if none_word!= ''
      sub_match = none_word.split(/\s+/) 
      like_str = like_str + ' and query NOT REGEXP' +  '\'' + 
        sub_match.join("|") + '\''
    end

    return find_by_sql(
      [sql_stmt % like_str, query_date, year, week])
  end
end
