class WalmartTop32Items < BaseModel
  self.table_name = 'walmart_query_top_32_items'

  def self.get_items(query, year=nil, week=nil)
    item_selects = %q{item.item_id, item.item_revenue,
      item.shown_count, item.item_con, item.item_atc, item.item_pvr,
      total.revenue as site_revenue, item_attrs.title,
      item_attrs.image_url}
    join_stmt = %q{AS walmart_items LEFT OUTER JOIN 
      item_cat_total_revenue_week AS total 
      ON total.week = walmart_items.week AND
      total.item = walmart_items.item AND
      total.cat_id = 0
      LEFT OUTER JOIN all_item_attrs AS item_attrs ON 
      walmart_items.item = item_attrs.item_id
      LEFT OUTER JOIN item_query_cat_metrics_week as item ON
      walmart_items.year = item.year AND
      walmart_items.week = item.week AND
      walmart_items.query = item.query AND
      walmart_items.item = item.item_id AND
      item.cat_id = 0 AND 
      (item.channel = "ORGANIC" or item.channel = "ORGANIC_USER")}
    joins(join_stmt).select(item_selects).where(
      %q{walmart_items.year = ? AND walmart_items.week = ? AND
      walmart_items.query = ?}, year, week, query).order(
      'walmart_items.position ASC')
  end
end
