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
    sum(item_metrics.uniq_oos)/sum(item_metrics.uniq_count)*100 
    i_oos}
   
    joins(join_stmt).select(selects).where(
      where_str, query_dates, item_id_list, query).group(
        'item_metrics.item_id')
  end
  
  def self.get_items(query, items, query_date)
    query_date = query_date.strftime('%Y-%m-%d')
    # by deviding it into small set first, we could optimize this query 
    # from 1.5s to 50ms
    sql_statement = %q{
     select 
     a.item_id, a.image_url, a.curr_item_price, a.title,
     b.uniq_count shown_count, b.i_con, b.i_oos, b.i_atc, b.i_pvr
     from 
     (select item_id, image_url, curr_item_price, title from `all_item_attrs` 
     where item_id in (?))a
     LEFT OUTER JOIN 
     (select item_id, sum(revenue) revenue, sum(uniq_count) uniq_count, 
     sum(uniq_con)/sum(uniq_count)*100 i_con,
     sum(uniq_atc)/sum(uniq_count)*100 i_atc,
     sum(uniq_pvr)/sum(uniq_count)*100 i_pvr,
     sum(uniq_oos)/sum(uniq_count)*100 i_oos
     FROM item_query_metrics_daily WHERE item_id in (?) and
     query = ? and data_date = ?  AND channel in 
     ("ORGANIC_USER", 'ORGANIC_AUTO_COMPLETE')  AND 
     page_type = 'SEARCH' group by item_id) b
     on a.item_id = b.item_id order by Field(a.item_id, ?)}

     find_by_sql(
       [sql_statement, items, items, query, query_date, items])
  end
end
