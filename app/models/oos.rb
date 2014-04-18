class Oos < BaseModel
  self.table_name = 'cat_seg_query_oos_list'
 
  def self.get_queries(winning, query_segment, cat_id, data_date,
                       page=1,  limit=10, order_col=nil, order='asc')
    cols = nil
    if winning
      default_order = 'score asc'
    else
      default_order = 'score desc'
    end
    order_str = order_col.nil? ? default_order : 
      order.nil? ? order_col : %Q{#{order_col} #{order}}
    offset = (page - 1) * 10
    
    if page == 0
      order_limit_str = ''
      cols = %q{query}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end
   
    cols ||= %q{query, 
    query_count c_o_u_n_t,
    rank_score score,
    oos o_o_s,
    pvr p_v_r,
    atc a_t_c,
    conversion c_o_n}

    where_str = %q{oos != '' and cat_id = ? and data_date = ? and 
      segmentation = ?}

    select(cols).where(
      [where_str, cat_id, data_date, query_segment]).order(
        order_limit_str) 
  end

  def self.get_distribution(query_segment, cat_id, data_date)
    find_by_sql([%q{select cat, count(*) vol from 
      (select query, if(query_count<200,200,if(query_count<400,400,if(query_count<600,600,if(query_count<800,800,if(query_count<1000,1000,if(query_count<1200,1200,if(query_count<1400,1400,if(query_count<1600,1600,if(query_count<1800,1800,2000))))))))) cat 
      from (select s.query query, sum(s.uniq_count) query_count FROM 
      query_cat_metrics_daily as s JOIN query_segmentation_daily qs ON 
      ( s.query=qs.query and s.data_date=qs.data_date )
      where s.cat_id= ? and s.page_type='SEARCH' and s.channel in 
      ('ORGANIC_USER','ORGANIC_AUTO_COMPLETE') and 
      s.data_date = ? and qs.cat_id=0 and qs.segmentation= ? group by 
      s.query)a)b group by cat},cat_id, data_date, query_segment])
  end
end
