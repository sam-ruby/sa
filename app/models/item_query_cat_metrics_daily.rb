class ItemQueryCatMetricsDaily < BaseModel
  set_table_name 'item_query_cat_metrics_daily'

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
        AND item.cat_id = ? AND (item.channel = "ORGANIC" or 
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
        AND item.cat_id = ? AND (item.channel = "ORGANIC" or 
        item.channel = "ORGANIC_USER") AND item.item_id in (?)},
        date, query, cat_id, item_ids).order(
          'item_revenue DESC, shown_count DESC').limit(32)
  end

  # for a range of time get the popular items
  def self.get_walmart_items_over_time(query, start_date, end_date)
    sql_for_item_ids = 
     "select item_id,
     sum(shown_count) as sum_shown_count,
     sum(item_pvr *shown_count)/sum(shown_count) as item_pvr_ave,
     sum(item_con *shown_count)/sum(shown_count) as item_con_ave,
     sum(item_atc *shown_count)/sum(shown_count) as item_atc_ave
     from item_query_cat_metrics_daily 
     where query_date in (?) and query = ? and cat_id = 0 and (channel = 'ORGANIC' or channel = 'ORGANIC_USER') 
     group by item_id
     
     order by sum_shown_count DESC,item_pvr_ave DESC, item_atc_ave DESC limit 32"

    date_range = start_date..end_date

    ids = ItemQueryCatMetricsDaily.find_by_sql([sql_for_item_ids, date_range, query])
    ids_array = Array.new

    ids.each { |x| 
      ids_array << x.item_id 
    }
    # if I direct do join it will be very slow to join item_query_cat_metrics_daily and all_items_attrs
    sql_for_items =
    "select b.title, b.image_url, b.curr_item_price,
     a.item_con_ave as item_con, a. item_pvr_ave as item_pvr,
     a.item_atc_ave as item_atc, a.sum_item_revenue as item_revenue, a.sum_shown_count as shown_count from
     (
     select item_id,
     sum(shown_count) as sum_shown_count,
     sum(item_pvr *shown_count)/sum(shown_count) as item_pvr_ave,
     sum(item_con *shown_count)/sum(shown_count) as item_con_ave,
     sum(item_atc *shown_count)/sum(shown_count) as item_atc_ave,
     sum(item_revenue) as sum_item_revenue
     from item_query_cat_metrics_daily 
     where query_date in (?) and query = ? and cat_id = 0 and (channel = 'ORGANIC' or channel = 'ORGANIC_USER')
      group by item_id
     
     order by sum_shown_count DESC,item_pvr_ave DESC, item_atc_ave DESC limit 32
     )a
     left join 
     (select item_id, title, image_url, curr_item_price from all_item_attrs where item_id in (?)) b
     on b.item_id = a.item_id
    "
   items =ItemQueryCatMetricsDaily.find_by_sql([sql_for_items, date_range, query, ids_array])

    return items

    # select * from item_query_cat_metrics_daily where query_date in ('2013-07-07', '2013-07-09') and query = "dora" and cat_id = 0 and channel = 'ORGANIC' or 'ORGANIC_USER' order by item_pvr DESC limit 32

  end

end
