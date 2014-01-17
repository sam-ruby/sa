class AllItemAttrs < BaseModel
  self.table_name = 'all_item_attrs'

  def self.get_item_details(query, item_id_list, query_date, query_dates)
    item_ids = item_id_list.map {|x| "'#{x.to_s}'"}.join(',')
    query = sanitize_sql_array([%q{'%s'}, query])

    join_stmt = %Q{as item_attrs left outer join 
    (select item_id, sum(revenue)/14 as item_revenue from 
    item_query_metrics_daily 
    where item_id in (#{item_ids}) and 
    data_date in (#{query_dates.join(',')}) 
    and query = #{query} and 
    channel = "ORGANIC_USER" and page_type = 'SEARCH'
    group by item_id) as item on 
    item.item_id = item_attrs.item_id
    left outer join (select item_id, sum(revenue)/14 as total_revenue
    from item_cat_metrics_daily where data_date in
    (#{query_dates.join(',')}) and item_id in (#{item_ids})
    and cat_id = 0 group by item_id) as item_site_revenue on
    item_site_revenue.item_id = item_attrs.item_id}

    selects = %q{item_attrs.item_id, item_attrs.title, 
    item_attrs.image_url, item_attrs.curr_item_price, 
    item.item_revenue, item_site_revenue.total_revenue}
   
    joins(join_stmt).select(selects).where(
      %q{item_attrs.item_id in (?)}, item_id_list)
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
