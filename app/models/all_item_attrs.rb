class AllItemAttrs < BaseModel
  self.table_name = 'all_item_attrs'

  def self.get_item_details(item_id_list)
    self.where('item_id in (?)', item_id_list)
  end
  
  def self.get_items(query, items, query_date)
    query_date = query_date.strftime('%Y-%m-%d')
    item_selects = %q{item.item_id, item.item_revenue,
      item.shown_count, item.item_con, item.item_atc, item.item_pvr,
      total.revenue as site_revenue, item_attr.title,
      item_attr.image_url}
    join_stmt = %Q{AS item_attr LEFT OUTER JOIN 
      item_cat_total_revenue_daily AS total ON 
      total.date = '#{query_date}' AND
      total.item = item_attr.item_id AND
      total.cat_id = 0
      LEFT OUTER JOIN item_query_cat_metrics_daily as item ON
      item.query_date = '#{query_date}' AND
      item.query = '#{query}' AND
      item_attr.item_id = item.item_id AND
      item.cat_id = 0 AND 
      (item.channel = "ORGANIC" or item.channel = "ORGANIC_USER")}
    joins(join_stmt).select(item_selects).where(
      %q{item_attr.item_id in (?)}, items)
  end

end
