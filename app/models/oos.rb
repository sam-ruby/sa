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
    find_by_sql([%q{select c.bin cat, if (b.bin is null, c.count, b.count) vol
    from (select bin, count(*) as count from (select query, 
    if(oos=0, 10, CEILING(oos/10)*10) as bin from 
    cat_seg_query_oos_list where data_date=? and cat_id=? and 
    segmentation=?)a group by bin order by bin)b 
    right outer join 
    (select 10 as bin, 0 as count
    union all select 20 as bin, 0 as count 
    union all select 30 as bin, 0 as count
    union all select 40 as bin, 0 as count
    union all select 50 as bin, 0 as count
    union all select 60 as bin, 0 as count
    union all select 70 as bin, 0 as count 
    union all select 80 as bin, 0 as count
    union all select 90 as bin, 0 as count
    union all select 100 as bin, 0 as count)c on 
    b.bin=c.bin order by c.bin}, data_date, cat_id, query_segment])
  end
end
