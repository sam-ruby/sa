class Ndcg < BaseModel
  self.table_name = 'query_ndcg_metrics'
  
  def self.get_distribution(data_date)
    cols = %q{round(ndcg,1) ndcg_cat, count(*) query_vol}
    select(cols).where(%q{data_date = ?}, data_date).group('round(ndcg, 1)')
  end

  def self.get_daily_metrics(segment, cat_id, date)
    cols = %q{n.data_date, avg(n.ndcg) score,
      if(count(*)>1000,100,count(*)/10) confidence}

    join_str = %q{as n JOIN query_segmentation_daily s ON 
      (n.query=s.query and n.data_date=s.data_date ) 
      JOIN query_categorization_daily c ON 
      (n.query=c.query and n.data_date=c.data_date)}

    where_str = %q{n.data_date in (?, ?) and 
      s.segmentation = ? and c.cat_id = ?}

    select(cols).joins(join_str).where(
      [where_str, date, date - 1.day, segment, cat_id]).group(
        'n.data_date').order('n.data_date desc') 
  end
  
  def self.get_queries(winning, query, query_segment, cat_id, data_date,
                       page=1,  limit=10, order_col=nil, order='asc')
  
    cols = nil
    order_str = order_col.nil? ? 'score desc' : 
      order.nil? ? order_col : %Q{#{order_col} #{order}}
    offset = (query.nil? or query.empty?) ? (page - 1) * 10 : 0
    
    if page == 0
      order_limit_str = ''
      cols = %q{n.query, n.ndcg, sum(q.uniq_count) count}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end

    unless winning
      cols ||= %q{n.query, n.ndcg, sum(q.uniq_count) count, 
      round((sum(q.uniq_count)+0.001)/(ndcg+0.001),2) score}
    else
      cols ||= %q{n.query, n.ndcg, sum(q.uniq_count) count, 
      round((pow(sum(q.uniq_count), 2)+0.001)*(ndcg+0.001),2) score}
    end

    join_str = %q{as n JOIN query_cat_metrics_daily q ON 
      (q.query=n.query and q.data_date = n.data_date) 
      JOIN query_segmentation_daily s ON 
      (s.query=n.query and s.data_date=n.data_date) 
      JOIN query_categorization_daily c ON 
      (c.query=n.query and c.data_date=n.data_date)}

    where_str = %q{q.page_type='SEARCH' and q.channel in 
      ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE') and 
      s.segmentation = ? and 
      q.cat_id = 0 and 
      c.cat_id = ? and 
      n.data_date=? and 
      n.query!=''}

    select(cols).joins(join_str).where(
      [where_str, query_segment, cat_id, data_date]).group('q.query').having(
        'count > 500').order(order_limit_str)
  end
end
