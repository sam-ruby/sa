class ItemQueryCatMetricsWeekly < BaseModel
  self.table_name = 'item_query_cat_metrics_week'

  def self.get_walmart_items(query, cat_id, week=nil, year=nil)
      item_selects = %q{item.item_id, item.item_revenue,
        item.shown_count, item.item_con, item.item_atc, item.item_pvr,
        total.revenue as site_revenue, item_attrs.title,
        item_attrs.image_url}
      join_stmt = %q{AS item LEFT OUTER JOIN 
        item_cat_total_revenue_week AS total ON total.year =
        item.year AND total.week = item.week AND total.cat_id = item.cat_id AND
        total.item = item.item_id 
        LEFT OUTER JOIN all_item_attrs AS item_attrs ON 
        item.item_id = item_attrs.item_id}
      self.joins(join_stmt).select(
        item_selects).where(%q{item.year = ? AND item.week = ? AND item.query = ? 
        AND item.cat_id = ? AND item.channel = "ORGANIC"}, year, week, query, 
        cat_id).order('item_revenue DESC, shown_count DESC').limit(32)
  end
end
