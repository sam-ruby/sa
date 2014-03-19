class SearchQualityDaily < BaseModel
  self.table_name = 'search_quality_daily'
  def self.get_search_relevance_data(
    query_date, page=1, order_col='uniq_count', order='asc', limit=10)
    
    order_str = order_col.nil? ? 
      'uniq_count desc, search_con_rank_correlation asc' : 
      order.nil? ? order_col : order_col + ' ' + order  
    
    select(%q{query, data_date, uniq_count, revenue,
    search_con_rank_correlation, query_items, con_ranks,
           top_con_items}).where(
             'data_date = ? ', query_date).order(order_str).page(
               page).per(limit)
  end
 
  def self.get_search_relevance_data_by_id(id)
    self.select(%q{id, query, query_items, top_rev_items}).where(
      'id = ?', id)
  end

  def self.get_search_relevance_data_by_word(query_str, query_date)
    select(%q{query, data_date, uniq_count, revenue,
           search_con_rank_correlation, 32_query_items, con_ranks, 
           top_con_items, top_16_con, top_16_site_revenue}
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
    offset = (query.nil? or query.empty?) ? (page - 1) * 10 : 0
    order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}

    sql_stmt = %Q{select query, search_con_rank_correlation,
      query_count, query_con order_count, revenue, cat_rate, show_rate, 
      rel_score, conversion_rate query_con,
      if(cat_rate is null, pow(query_count,2)/(query_con+1)*30/1000,
      pow(query_count,2)/(query_con+1)*(cat_rate-show_rate)/1000) 
      rank_metric
      from 
      (SELECT a.query as query, search_con_rank_correlation, 
      sum(b.uniq_count) query_count, 
      sum(b.uniq_con) query_con,
      sum(b.revenue) as revenue, 

      (select assort_overlap_indexed*100 from query_performance_week 
      where week=#{week} and year=#{year} and query = a.query) as cat_rate, 
      
      (select shown_overlap*100 from query_performance_week 
      where week=#{week} and year=#{year} and query=a.query) as show_rate, 
      
      (select rel_score from query_performance_week where 
      week=#{week} and year=#{year} and query=a.query) as rel_score, 
      
      sum(b.uniq_con)/sum(b.uniq_count)*100 conversion_rate 
      FROM search_quality_daily as a, query_cat_metrics_daily as b 
      WHERE 
      a.data_date = b.data_date and 
      a.query=b.query and 
      b.cat_id=0 and 
      b.page_type='SEARCH' and 
      b.channel in ('ORGANIC_USER','ORGANIC_AUTO_COMPLETE') and 
      a.data_date= ? %s group by b.query)c 
      #{order_limit_str}}

    if query.nil? or query.empty? 
      return find_by_sql([sql_stmt % '', query_date])
    end  
    
    my_match= /^EXACT_WORD=(.*)ALL_WORD=(.*)ANY_WORD=(.*)NONE_WORD=(.*)$/.match(query)  

    if my_match.nil?  
      return find_by_sql(
        [sql_stmt % "and a.query = '#{query}'", query_date])
    end

    exact_word = my_match[1]
    if exact_word!= ''
      return find_by_sql(
        [sql_stmt % "and a.query = '#{exact_word}'", query_date])
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
      like_str= like_str +'and a.query like'  + '\'' + 
        sub_match.join(' ') + '\''
    end

    #REGEXP 'ipad|mini'
    if any_word!= ''
      sub_match = any_word.split(/\s+/) 

      like_str = like_str + ' and a.query REGEXP' +  '\'' + 
        sub_match.join("|") + '\''
    end

    #NOT REGEXP 'heater|desk'
    if none_word!= ''
      sub_match = none_word.split(/\s+/) 
      like_str = like_str + ' and q.uery NOT REGEXP' +  '\'' + 
        sub_match.join("|") + '\''
    end

    return find_by_sql(
      [sql_stmt % like_str, query_date])
  end
end
