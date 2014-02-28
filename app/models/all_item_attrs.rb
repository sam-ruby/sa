class AllItemAttrs < BaseModel
  self.table_name = 'all_item_attrs'

  def self.get_item_details(query, item_id_list, query_dates)
    # item_ids = item_id_list.map {|x| "'#{x.to_s}'"}.join(',')
    query = sanitize_sql_array([query])

    join_stmt = %q{as item_attrs, item_query_metrics_daily as item_metrics}
    where_str = %q{item_attrs.item_id = item_metrics.item_id and
      item_metrics.page_type = 'SEARCH' and 
      item_metrics.channel in ("ORGANIC_USER", "ORGANIC_AUTO_COMPLETE") and 
      item_metrics.data_date in (?) and 
      item_attrs.item_id in (?) and 
      item_metrics.query = ?}
    selects = %q{item_attrs.item_id, item_attrs.title, 
      item_attrs.image_url, item_attrs.curr_item_price, 
      sum(item_metrics.revenue)/28 item_revenue}

    selects = %q{item_attrs.item_id, item_attrs.title, 
    item_attrs.image_url, item_attrs.curr_item_price, 
    sum(item_metrics.revenue)/28 item_revenue}
   
    joins(join_stmt).select(selects).where(
      where_str, query_dates, item_id_list, query).group(
        'item_metrics.item_id')
  end
  
  def self.get_items(query, items, query_date)
    query_date = query_date.strftime('%Y-%m-%d')
    # by deviding it into small set first, we could optimize this query from 1.5s to 50ms
    sql_statement = %q{
     select 
     a.item_id, a.image_url, a.curr_item_price, a.title,
     b.revenue, b.uniq_count, b.con, b.atc, b.pvr,
     c.revenue as site_revenue from (
     (select item_id, image_url, curr_item_price, title from `all_item_attrs` 
     where item_id in (?))a

     LEFT OUTER JOIN 

     (select item_id, revenue, uniq_count, (uniq_con/uniq_count)*100 con,
     (uniq_atc/uniq_count)*100 atc, (uniq_pvr/uniq_count)*100 pvr 
     FROM item_query_metrics_daily WHERE item_id in (?) and
     query = ? and data_date = ?  AND channel = "ORGANIC_USER"  AND 
     page_type = 'SEARCH') b

     on a.item_id = b.item_id
     
     left outer join 
     (SELECT item_id, revenue FROM item_cat_metrics_daily WHERE cat_id = 0 AND
     data_date = ? and item_id in (?)) c on a.item_id = c.item_id
     )}

    items = find_by_sql([sql_statement,items, items, query, query_date, query_date, items ])

    # item_selects = %q{item_attr.item_id, item.item_revenue,
    #   item.shown_count, item.item_con, item.item_atc, item.item_pvr,
    #   total.revenue as site_revenue, item_attr.title,
    #   item_attr.image_url}
    # join_stmt = %Q{AS item_attr LEFT OUTER JOIN (SELECT item,
    # revenue FROM item_cat_total_revenue_daily WHERE cat_id = 0 AND 
    # date = '#{query_date}') AS total ON total.item = item_attr.item_id
    # left outer join (select item_id, item_revenue, shown_count, item_con,
    # item_atc, item_pvr FROM item_query_cat_metrics_daily WHERE
    # query_date = '#{query_date}' AND query = '#{query}' AND cat_id = 0
    # AND (channel = "ORGANIC" or channel = "ORGANIC_USER")) AS item ON
    # item_attr.item_id = item.item_id}
    # joins(join_stmt).select(item_selects).where(
    #   %q{item_attr.item_id in (?)}, items)
  end
end
