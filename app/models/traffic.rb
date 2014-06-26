class Traffic < BaseModel
  self.table_name = 'query_cat_metrics_daily'
 
  def self.get_daily_metrics(segment, cat_id, date)
    cols = %q{s.data_date, sum(s.uniq_count) score}
    
    join_str = %q{as s JOIN query_segmentation_daily qs ON 
      (s.query=qs.query and s.data_date=qs.data_date )} 

    where_str = %q{s.cat_id = 0 and s.page_type = 'SEARCH' and
    s.channel in ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE')  and 
    s.data_date in (?, ?) and qs.segmentation = ? and qs.cat_id = ?}

    select(cols).joins(join_str).where(
      [where_str, date, date - 1.day, segment, cat_id]).group(
        's.data_date').order('s.data_date desc') 
  end

  def self.get_queries(winning, query_segment, cat_id, data_date,
                       filter_by=nil, filter_cond=nil, user_id=nil,
                       page=1,  limit=10, 
                       order_col=nil, order='asc')
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
      cols = %q{s.query}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end
   
    cols ||= %q{s.query, uq.rating,
    sum(s.uniq_count) c_o_u_n_t,
    pow(sum(s.uniq_count),2)/(sum(s.uniq_con)/sum(s.uniq_count)+0.01) score,
    sum(s.uniq_pvr)/sum(s.uniq_count)*100 p_v_r,
    sum(s.uniq_atc)/sum(s.uniq_count)*100 a_t_c,
    sum(s.uniq_con)/sum(s.uniq_count)*100 c_o_n}

    join_str = %Q{as s JOIN query_segmentation_daily qs ON 
      (s.query=qs.query and s.data_date=qs.data_date )
      LEFT OUTER JOIN user_rated_queries uq on
      s.query = uq.query and
      uq.metric_name = 'all' and
      uq.user_id = '#{user_id}'}
    
    where_str = %q{s.cat_id = 0 and s.page_type = 'SEARCH' and
    s.channel in ('ORGANIC_USER', 'ORGANIC_AUTO_COMPLETE')  and 
    s.data_date in (?) and qs.segmentation = ? and qs.cat_id = ?}
    
    if filter_by and filter_cond
      if filter_by == 'rating' and filter_cond == 'with_good'
        where_str += %q{ and (uq.rating is null or uq.rating = 1) }
      elsif filter_by == 'rating' and filter_cond == 'only_good'
        where_str += %q{ and uq.rating = 1}
      end
    end

    select(cols).joins(join_str).where(
      [where_str, data_date, query_segment, cat_id]).group('s.query').order(
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
  
  def self.get_stats(query_segment, cat_id)
    cols = %q{unix_timestamp(s.data_date) * 1000 data_date,
    sum(s.uniq_count) score}
    
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
