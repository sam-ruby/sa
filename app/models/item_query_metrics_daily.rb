class ItemQueryMetricsDaily < BaseModel
  set_table_name 'item_query_metrics_daily'

  def self.get_walmart_items(query, cat_id, date=nil, year=nil,
                             week=nil)
      item_selects = %q{item.item_id, item.item_revenue,
        item.shown_count, item.item_con, item.item_atc, item.item_pvr,
        total.revenue as site_revenue, item_attrs.title,
        item_attrs.image_url}
      join_stmt = %q{AS item LEFT OUTER JOIN 
        item_cat_total_revenue_daily AS total ON total.date =
        item.query_date AND total.cat_id = item.cat_id AND
        total.item = item.item_id 
        LEFT OUTER JOIN all_item_attrs AS item_attrs ON 
        item.item_id = item_attrs.item_id}
      ItemQueryCatMetricsDaily.joins(join_stmt).select(
        item_selects).where(%q{item.query_date = ? AND item.query = ? 
        AND item.cat_id = ? AND (item.channel = "ORGANIC_AUTO_COMPLETE" or 
                            item.channel = "ORGANIC_USER")}, date, query, 
        cat_id).order('item_revenue DESC, shown_count DESC').limit(32)
  end
  
  def self.get_walmart_items_by_item_ids(
    query, item_ids, date=nil, year=nil, week=nil)
      item_selects = %q{item.item_id, item.item_revenue,
        item.shown_count, item.item_con, item.item_atc, item.item_pvr,
        total.revenue as site_revenue, item_attrs.title,
        item_attrs.image_url}
      join_stmt = %q{AS item LEFT OUTER JOIN 
        item_cat_total_revenue_daily AS total ON total.date =
        item.query_date AND total.cat_id = item.cat_id AND
        total.item = item.item_id 
        LEFT OUTER JOIN all_item_attrs AS item_attrs ON 
        item.item_id = item_attrs.item_id}
      ItemQueryCatMetricsDaily.joins(join_stmt).select(
        item_selects).where(%q{item.query_date = ? AND item.query = ? 
        AND item.cat_id = ? AND (item.channel = "ORGANIC_AUTO_COMPLETE" or 
        item.channel = "ORGANIC_USER") AND item.item_id in (?)},
        date, query, cat_id, item_ids).order(
          'item_revenue DESC, shown_count DESC').limit(32)
  end

  # for a range of time get the popular items
  def self.get_walmart_items_over_time(query, start_date, end_date)
    
    date_range = start_date..end_date
    
    select_cols = %q{item.item_id, sum(uniq_count) shown_count, 
    sum(uniq_pvr)/sum(uniq_count)*100 i_pvr,
    sum(uniq_con)/sum(uniq_count)*100 i_con,
    sum(uniq_atc)/sum(uniq_count)*100 i_atc, 
    sum(revenue) as revenue,
    item.title, item.image_url, item.curr_item_price}

    join_stmt = %q{as item_daily left outer join all_item_attrs item
    on item_daily.item_id = item.item_id}

    joins(join_stmt).select(select_cols).where(
      %q{item_daily.data_date in (?) and query = ? and channel = 'ORGANIC_USER' 
      and page_type = 'SEARCH'}, date_range, query).group(
        'item_daily.item_id').order(
        'shown_count DESC, i_pvr DESC, i_atc DESC').limit(32)
  end
end
