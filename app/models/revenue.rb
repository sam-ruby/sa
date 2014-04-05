class Revenue < BaseModel
  self.table_name = 'query_cat_metrics_daily'
 
  def self.get_queries(winning, query_segment, cat_id, data_date,
                       page=1,  limit=10, order_col=nil, order='asc')
    cols = nil
    if winning
      default_order = 'score desc'
    else
      default_order = 'score asc'
    end
    order_str = order_col.nil? ? default_order : 
      order.nil? ? order_col : %Q{#{order_col} #{order}}
    offset = (page - 1) * 10
    
    if page == 0
      order_limit_str = ''
      cols = %q{s.query}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end
   
    cols ||= %q{s.query,
     sum(s.uniq_count) c_o_u_n_t, 
     sum(s.uniq_pvr)/sum(s.uniq_count)*100 p_v_r,
     sum(s.uniq_atc)/sum(s.uniq_count)*100 a_t_c,
     sum(s.uniq_con)/sum(s.uniq_count)*100 c_o_n,
     sum(s.revenue) score}

    join_str = %q{as s JOIN query_segmentation_daily qs ON 
      (s.query=qs.query and s.data_date=qs.data_date )}

    where_str = %q{s.cat_id = 0 and s.page_type = 'SEARCH' and
    s.channel in ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE')  and 
    s.data_date in (?) and qs.segmentation = ? and qs.cat_id = ?}

    select(cols).joins(join_str).where(
      [where_str, data_date, query_segment, cat_id]).group('s.query').order(
        order_limit_str) 
  end

  def self.get_distribution(query_segment, cat_id, data_date)
    find_by_sql([%q{select cat, count(*) vol from 
      (select query, if(revenue<300,300,if(revenue<600,600,if(revenue<900,900,if(revenue<1200,1200,if(revenue<1500,1500,if(revenue<1800,1800,if(revenue<2100,2100,if(revenue<2400,2400,if(revenue<2700,2700,3000))))))))) cat
      from (select s.query query, sum(s.revenue) revenue
      FROM 
      query_cat_metrics_daily as s JOIN query_segmentation_daily qs ON 
      ( s.query=qs.query and s.data_date=qs.data_date )
      where s.cat_id= ? and s.page_type='SEARCH' and s.channel in 
      ('ORGANIC_USER','ORGANIC_AUTO_COMPLETE') and 
      s.data_date = ? and qs.cat_id=0 and qs.segmentation= ? group by 
      s.query)a)b group by cat},cat_id, data_date, query_segment])
  end
  
  def self.get_stats(query_segment, cat_id)
    cols = %q{unix_timestamp(s.data_date) * 1000 data_date, 
    sum(s.revenue) score}
    
    join_str = %q{as s JOIN query_segmentation_daily qs ON 
      (s.query=qs.query and s.data_date=qs.data_date )} 

    where_str = %q{s.cat_id = 0 and s.page_type = 'SEARCH' and
    s.channel in ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE')  and 
    qs.segmentation = ? and qs.cat_id = ?}
    
    select(cols).joins(join_str).where(
      [where_str, query_segment, cat_id]).group(
        's.data_date') 
  end
end
