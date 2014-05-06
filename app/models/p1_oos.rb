class P1Oos < BaseModel
  self.table_name = 'cat_seg_query_p1_oos'
  
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
    offset = (page - 1) * limit
    
    if page == 0
      order_limit_str = ''
      cols = %q{query}
    else
      order_limit_str = %Q{ #{order_str} limit #{limit} offset #{offset}}
    end
   
    cols ||= %q{query, 
    query_count c_o_u_n_t,
    rank_score score,
    p1_oos o_o_s,
    pvr p_v_r,
    atc a_t_c,
    conversion c_o_n}

    where_str = %q{p1_oos != '' and cat_id = ? and data_date = ? and 
      segmentation = ?}

    select(cols).where(
      [where_str, cat_id, data_date, query_segment]).order(
        order_limit_str) 
  end
end
