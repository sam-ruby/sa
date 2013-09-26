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
end
