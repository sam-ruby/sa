class AllItemAttrs < BaseModel
  self.table_name = 'all_item_attrs'

  def self.get_item_details(query, item_id_list, query_date, query_dates)
    query = sanitize_sql_array([%q{'%s'}, query])

    selects = %Q{item_id, title, image_url, curr_item_price, 
    (select sum(item_revenue)/7 
    from item_query_cat_metrics_daily where 
    query_date in (#{query_dates.join(',')}) and
    query = #{query} and item_id = all_item_attrs.item_id and 
    (channel = "ORGANIC" or channel = "ORGANIC_USER")
    and cat_id = 0) as item_revenue}
    
    select(selects).where(%q{item_id in (?)}, item_id_list)
  end
  
  def self.get_items(query, items, query_date)
    query_date = query_date.strftime('%Y-%m-%d')
    item_selects = %q{item_attr.item_id, item.item_revenue,
      item.shown_count, item.item_con, item.item_atc, item.item_pvr,
      total.revenue as site_revenue, item_attr.title,
      item_attr.image_url}
    join_stmt = %Q{AS item_attr LEFT OUTER JOIN (SELECT item,
    revenue FROM item_cat_total_revenue_daily WHERE cat_id = 0 AND 
    date = '#{query_date}') AS total ON total.item = item_attr.item_id
    left outer join (select item_id, item_revenue, shown_count, item_con,
    item_atc, item_pvr FROM item_query_cat_metrics_daily WHERE
    query_date = '#{query_date}' AND query = '#{query}' AND cat_id = 0
    AND (channel = "ORGANIC" or channel = "ORGANIC_USER")) AS item ON
    item_attr.item_id = item.item_id}
    joins(join_stmt).select(item_selects).where(
      %q{item_attr.item_id in (?)}, items)
  end
end
