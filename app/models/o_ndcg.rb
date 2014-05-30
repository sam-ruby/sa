class ONdcg < BaseModel
  self.table_name = 'query_metrics_daily'
 
  def self.get_queries(winning, query_segment, cat_id, data_date,
                       metric_name, page=1,  limit=10, order_col=nil, order='asc')
    cols = nil
    if winning
      default_order = 'score asc'
    else
      default_order = 'score desc'
    end
    order_str = order_col.nil? ? default_order : 
      order.nil? ? order_col : %Q{#{order_col} #{order}}
    offset = (page - 1) * limit
    
    if page == 0
      order_limit_str = ''
      cols = %q{a.query}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end
   
    cols ||= %q{a.query, 
      SUM(b.uniq_count) c_o_u_n_t,
      SUM(b.uniq_con)/SUM(b.uniq_count)*100 c_o_n, 
      SUM(b.uniq_pvr)/SUM(b.uniq_count)*100 p_v_r, 
      SUM(b.uniq_atc)/SUM(b.uniq_count)*100 a_t_c,
      if(a.metric_value<0.1 and sum(b.uniq_count)>1000,
      sum(b.uniq_count)/(a.metric_value+0.01),
      if(sum(b.uniq_count)<500,
      sum(b.uniq_count)*(1-a.metric_value)*0.1,
      sum(b.uniq_count)*(1-a.metric_value))) score,
      a.metric_value}

    join_str = %q{as a INNER JOIN query_cat_metrics_daily b ON
      (a.data_date = b.data_date and a.query = b.query) 
      INNER JOIN query_segmentation_daily c ON 
      (a.query=c.query and a.data_date=c.data_date)}

    where_str = %q{b.cat_id = 0 and b.page_type = 'SEARCH' and
    b.channel in ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE')  and 
    a.data_date in (?) and a.metric_name = ? and c.segmentation = ? and 
    c.cat_id = ? and a.query NOT IN (select query from query_instore_only)}

    select(cols).joins(join_str).where(
      [where_str, data_date, metric_name, query_segment, cat_id]).group(
        'a.query').order(order_limit_str) 
  end
end
