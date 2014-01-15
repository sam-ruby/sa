class SearchQualityDaily < BaseModel
  self.table_name = 'search_quality_daily'
  def self.get_search_relevance_data(
    query_date, page=1, order_col='uniq_count', order='asc', limit=10)
    order_str = order_col.nil? ? 'uniq_count desc, search_rev_rank_correlation asc' : order.nil? ? order_col : order_col + ' ' + order  
    
    self.select(%q{query, data_date, uniq_count, revenue, 
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
    
    order_str = order_col.nil? ? 'rank_metric desc' : 
      order.nil? ? order_col : order_col + ' ' + order  
    
    join_stmt = %Q{as search_daily join query_cat_metrics_daily as query_daily 
    on search_daily.data_date = query_daily.data_date and
    search_daily.query = query_daily.query}

    selects = %Q{search_daily.query,
    search_daily.search_rev_rank_correlation, query_daily.uniq_count,
    query_daily.uniq_pvr/query_daily.uniq_count query_pvr,
    query_daily.uniq_atc/query_daily.uniq_count query_atc, 
    (query_daily.uniq_con/query_daily.uniq_count)*100 query_con,
    sum(query_daily.revenue) revenue, 
    (select assort_overlap * 100 from query_performance_week where year = #{year}
      and week = #{week} and query = search_daily.query 
      limit 1) as cat_rate, 
    (select shown_overlap * 100 from query_performance_week where year = #{year}
      and week = #{week} and query = search_daily.query 
      limit 1) as show_rate, 
    (select rel_score from query_performance_week where year = #{year}
      and week = #{week} and query = search_daily.query
      limit 1) as rel_score,    
    (select SQRT(query_daily.uniq_count)*(100-(
    query_daily.uniq_con/query_daily.uniq_count))*(
    cat_rate/100-show_rate/100)) as rank_metric}

    where_conditions = []
   
    if query.nil? or query.empty? 
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and query_daily.page_type = 'SEARCH' and 
        query_daily.channel = "ORGANIC_USER" and search_daily.data_date = 
        '%s'}, query_date])
      return joins(join_stmt).select(selects).where(where_conditions).order(order_str).page(page).per(limit)
    end  
    # query is like  'EXACT_WORD=niuniuALL_WORD=ipad miniANY_WORD=ppNONE_WORD='
    # my_match= /^EXACT_WORD=(.*)ALL_WORD=(.*)ANY_WORD=(.*)NONE_WORD=(.*)$/.match(query)
    my_match= /^EXACT_WORD=(.*)ALL_WORD=(.*)ANY_WORD=(.*)NONE_WORD=(.*)$/.match(query)  

    if my_match.nil?  
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and query_daily.page_type = 'SEARCH' and
        query_daily.channel = "ORGANIC_USER" and search_daily.data_date = 
        '%s' and search_daily.query = '%s'}, query_date, query])
      return joins(join_stmt).select(selects).where(where_conditions).order(order_str).page(page).per(limit)  
    end


    exact_word = my_match[1]
    if exact_word!= ''
      where_conditions = sanitize_sql_array([
        %q{query_daily.cat_id = 0 and query_daily.page_type = 'SEARCH' and
        query_daily.channel = "ORGANIC_USER" and search_daily.data_date = 
        '%s' and search_daily.query = '%s'}, query_date, exact_word])
      return joins(join_stmt).select(selects).where(where_conditions).order(order_str).page(page).per(limit)
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
      like_str= like_str +'and search_daily.query like'  + '\'' + sub_match.join(' ') + '\''
  
    end

    #REGEXP 'ipad|mini'
    if any_word!= ''
      sub_match = any_word.split(/\s+/) 

      like_str = like_str + ' and search_daily.query REGEXP' +  '\'' + sub_match.join("|") + '\''
    end

    #NOT REGEXP 'heater|desk'
    if none_word!= ''
      sub_match = none_word.split(/\s+/) 
      like_str = like_str + 'and search_daily.query NOT REGEXP' +  '\'' + sub_match.join("|") + '\''
    end

    statement = %q{query_daily.cat_id = 0 and query_daily.page_type = 'SEARCH' and
      query_daily.channel = "ORGANIC_USER" and search_daily.data_date = ?} + like_str

    where_conditions = sanitize_sql_array([statement, query_date])
    return joins(join_stmt).select(selects).where(where_conditions).order(order_str).page(page).per(limit)


    # if !query.nil? and query.include?('*')
    #   query = query.gsub('*', '%')
    #   where_conditions = sanitize_sql_array([
    #     %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
    #     query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
    #     '%s' and search_daily.query_str like '%s'}, query_date, query])
    # elsif !query.nil? and !query.empty?
    #   where_conditions = sanitize_sql_array([
    #     %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
    #     query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
    #     '%s' and search_daily.query_str = '%s'}, query_date, query])
    # else
    #   where_conditions = sanitize_sql_array([
    #     %q{query_daily.cat_id = 0 and (query_daily.channel = "ORGANIC" or 
    #     query_daily.channel = "ORGANIC_USER") and search_daily.query_date = 
    #     '%s'}, query_date])
    # end

    # joins(join_stmt).select(selects).where(where_conditions).order(order_str).page(page).per(limit)
  end
end
