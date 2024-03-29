# QueryDroppingConversion Model 
# @author Linghua Jin
# @since Dec, 2013

class QueryDroppingConversion < BaseModel
  self.table_name = 'trending_queries_daily'

  # for one query get the result for conversion rate comparison
  # SV. Making the line width to a reasonable size
  def self.get_cvr_dropped_query_with_query(
    query, weeks_apart,query_date,page,limit) 
    
    days_range = weeks_apart*7
    before_start_date = query_date-days_range
    before_end_date = query_date-1.day
    after_start_date = query_date
    after_end_date = query_date + days_range-1.day
    # rank was not really the rank in top 500, it will be modified into 
    # either "in top 500", or not "in top 500"
    
    sqlStatement = 
     'select null as is_in_top_500, b.query as query,
     b.sum_count as query_count_before,  b.con as query_con_before, b.revenue
     as query_revenue_before, d.sum_count as query_count_after, 
     d.con as query_con_after,
     d.revenue as query_revenue_after, b.con-d.con as query_con_diff, 
     (b.con-d.con)/d.con*d.revenue as expected_revenue_diff, 
     round(sqrt(d.sum_count)*(b.con-d.con), 0) as query_score from 
      (
        select 
          query, 
          sum(uniq_count) as sum_count, 
          sum(uniq_con)/sum(uniq_count) as con, 
          sum(revenue) as revenue 
         from query_cat_metrics_daily 
         where query=? and data_date between ? and ? and
         cat_id=0 and channel="ORGANIC_USER" and page_type = "SEARCH"
      )b 
      inner join 
      (
         select 
           query, 
           sum(uniq_count) as sum_count, 
           sum(uniq_con)/sum(uniq_count) as con, 
           sum(revenue) as revenue from query_cat_metrics_daily 
        where query = ? and data_date between ? and ? and cat_id=0 and 
        channel="ORGANIC_USER" and page_type = "SEARCH" 
      )d 
      on b.query=d.query'

    result_data = find_by_sql(
      [sqlStatement, query, before_start_date, before_end_date, 
       query, after_start_date, after_end_date]) 
     
    #requested by Ravi: they want to know if a searched result is in 
    #top 500 hundred or not
    #another alternative way is to cached the data from 
    #get_cvr_dropped_query_top_500 
    return result_data if result_data.length ==0
     
    in_top_500 = find_by_sql(
    ['select query, query_score from trending_queries_daily where
      query = ? and window_in_weeks = ? and data_date = ?', 
      query,weeks_apart, query_date]) 

     if in_top_500.length > 0
       result_data.first.is_in_top_500 = true
     else
       result_data.first.is_in_top_500 = false
     end
     result_data
  end

  def self.get_cvr_dropped_query_top_500(
    weeks_apart,query_date,order_col=nil,order='asc', page,limit)

    order_str = order_col.nil? ? 'query_score desc' : 
      order.nil? ? order_col : order_col + ' ' + order  

    select_cols = %q{query, query_con_before, query_count_before, 
    query_revenue_before, query_count_after, query_con_after, 
    query_revenue_after, query_con_after, query_con_diff, 
    ROUND(query_score, 2) as query_score, 
    query_con_diff/query_con_after*query_revenue_after 
    as expected_revenue_diff, (@rank := @rank + 1) AS rank}
    
    # defining the starting count for the rank. Like on second page, 
    # the rank should be 11,12,13. The page starting from 1,2,3,4.
    # the starting_rank is to form the from_statement
    starting_rank = ((page-1) * limit).to_s
    from_statement  =  "trending_queries_daily, (SELECT 
    @rank := " + starting_rank +") AS vars"
    select(select_cols).from(from_statement).where(
      %q{window_in_weeks = ? and data_date = ?},
      weeks_apart, query_date).order(order_str).page(page).per(limit)
  end

  def self.get_cvr_dropped_query_item_comparisons(
    query, weeks_apart, date)
   
    days_range = weeks_apart * 7
    data = date.to_date

    data_date_before, item_before_arr = get_top_items_between_date(
      query, date - (days_range * 2 ).days, date - (days_range).days) 
    data_date_after, item_after_arr = get_top_items_between_date(
      query, date - days_range.days, date) 
    
    #since this is a small list, it is ok to process the merge
    result_arr = Array.new(
      [(item_before_arr.length rescue 0), 
       (item_after_arr.length rescue 0)].max){Hash.new}

    result_arr.each_with_index { |val, index|
      # index starts with 0, when displaying it as rank in UI, 
      # it should start with 1;  
      if index < (item_before_arr.length rescue 0)
        val['cvr_dropped_item_comparison_rank'] = index+1
        val['item_id_before'] = item_before_arr[index]['item_id']
        val['item_title_before'] = item_before_arr[index]['title']
        val['image_url_before'] = item_before_arr[index]['image_url']
        val['seller_name_before'] = item_before_arr[index]['seller_name']
      end

      if index < (item_after_arr.length rescue 0)
        val['item_id_after'] = item_after_arr[index]['item_id']
        val['item_title_after'] = item_after_arr[index]['title']
        val['image_url_after'] = item_after_arr[index]['image_url']
        val['seller_name_after'] = item_after_arr[index]['seller_name']
      end
    }

    {data_date_before: data_date_before,
     data_date_after: data_date_after, 
     items: result_arr}
  end

  def self.get_top_items_between_date(query, date_start, date_end)
    item_ids = find_by_sql(
    ['select query_items, data_date from search_quality_daily where query = ?
      and data_date > ? and data_date <= ? order by data_date desc limit 1',
      query, date_start, date_end])
    return [] if item_ids.length == 0
    
    #process the result, split the string to array
    item_ids_arr = item_ids[0]['query_items'].split(",")
    data_date = item_ids.first.data_date
    
    #query item which id are in processed arr
    sql_statement = "select item_id, title, image_url, 
      (select seller_name from mp_seller_id_name_mapping_daily 
       where seller_id = all_item_attrs.seller_id order by data_date desc limit 1)
       seller_name 
       FROM all_item_attrs where item_id in (?) 
       order by Field(item_id, ?) "
    [data_date, find_by_sql([sql_statement, item_ids_arr, item_ids_arr])]
  end


  # this method is deprecated, but it is saved for 
  # performance improvement testing, don't remove now pls
  def self.get_cvr_dropped_query_slow(
    before_start_date,before_end_date,after_start_date,
    after_end_date,sum_count,page=1, limit=10)
    
    sqlStatement=
    'select query, con_before, con_after, diff, rev_before, rev_after from 
  (select b.query as query, b.con as con_before, d.con as con_after, 
    b.con-d.con as diff, b.revenue as rev_before, d.revenue as rev_after from 
    (select query, con, revenue from (
      select 
        query, 
        sum(query_count) as sum_count, 
        sum(query_count*query_con)/sum(query_count) as con, 
        sum(query_revenue) as revenue 
       from query_cat_metrics_daily 
       where query_date in (?) and 
       cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC") group by query having sum_count >= ? and con>0.02
     )a 
    )b 
    inner join 
    (select query,con, revenue from (
       select 
         query, 
         sum(query_count) as sum_count, 
         sum(query_count*query_con)/sum(query_count) as con, 
         sum(query_revenue) as revenue from query_cat_metrics_daily 
      where 
        query_date in (?) and cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC") 
        group by query having sum_count >=?
     )c 
    )d 

    on b.query=d.query)f where diff>0.02 order by diff desc;'

    before_date_arr=(before_start_date..before_end_date).map{ 
      |date| date.strftime("%Y-%m-%d")}
    after_date_arr=(after_start_date..after_end_date).map{ 
      |date| date.strftime("%Y-%m-%d")}

    result_data = find_by_sql(
      [sqlStatement, before_date_arr, sum_count, after_date_arr, sum_count]) 
  end
end
