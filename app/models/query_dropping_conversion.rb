# QueryDroppingConversion Model 
# @author Linghua Jin
# @since Dec, 2013

class QueryDroppingConversion < BaseModel
  self.table_name = 'queries_with_dropping_conversion'

  # for one query get the result for conversion rate comparison
  def self.get_cvr_dropped_query_with_query(query, weeks_apart,query_date,page,limit)
    days_range = weeks_apart*7
    before_start_date = query_date-days_range
    before_end_date = query_date-1.day
    after_start_date = query_date
    after_end_date = query_date + days_range-1.day
    sqlStatement = 
    'select b.query as query,b.sum_count as query_count_before,  b.con as query_con_before, b.revenue
     as query_revenue_before, d.sum_count as query_count_after, d.con as query_con_after,
    d.revenue as query_revenue_after, b.con-d.con as query_con_diff, d.con/b.con*b.revenue-d.revenue
     as expected_revenue_diff, sqrt(d.sum_count)*(b.con-d.con) as query_score 
  from 
    (
      select 
        query, 
        sum(query_count) as sum_count, 
        sum(query_count*query_con)/sum(query_count) as con, 
        sum(query_revenue) as revenue 
       from query_cat_metrics_daily 
       where query=? and query_date between ? and ? and
       cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC")
    )b 
    inner join 
    (
       select 
         query, 
         sum(query_count) as sum_count, 
         sum(query_count*query_con)/sum(query_count) as con, 
         sum(query_revenue) as revenue from query_cat_metrics_daily 
      where 
        query = ? and query_date between ? and ? and cat_id=0 and (channel="ORGANIC_USER" or channel="ORGANIC") 
    )d 
    on b.query=d.query'

     result_data = find_by_sql([sqlStatement, query, before_start_date, before_end_date, query, after_start_date, after_end_date]) 

  end

  def self.get_cvr_dropped_query_top_500(weeks_apart,query_date,page,limit)
    query_date = query_date.strftime("%Y-%m-%d")
    select_cols = %q{query, query_con_before, query_count_before, query_revenue_before,
     query_count_after, query_con_after, query_revenue_after, query_con_after, query_con_diff, 
     query_score, query_con_after/query_con_before*query_revenue_before-query_revenue_after 
     as expected_revenue_diff, 
     (@rank := @rank + 1) AS rank}
    # (@rank := @rank + 1) we need to calculate a rank number on the fly
    # defining the starting count for the rank. Like on second page, the rank should be 11,12,13. The page starting from 1,2,3,4.
    # the starting_rank is to form the from_statement
    starting_rank = ((page-1) * limit).to_s
    from_statement  =  "queries_with_dropping_conversion,(SELECT @rank := " + starting_rank +") AS vars"
    select(select_cols).from(from_statement)
      .where(%q{window_in_weeks = ? and data_date = ?}, weeks_apart, query_date)
      .page(page).per(limit)
  end


    # get item comparisons based on a query from cvr_dropped_query table, small set, client side pagination
  def self.get_cvr_dropped_query_item_comparisons(query, before_start_date,before_end_date,after_start_date,after_end_date)
    # reason for two separate resquest, need to merge two result into one row. Join(no join condition) and Union(will produce 15*15 results.) don't work. 
    # Plus, it is very small data set. total item count is 15
    # after_start_date is used for the query_date midpoint for two week before and  two week after
    item_before_arr = get_top_items_between_date(query, before_start_date, before_end_date, after_start_date) 
    item_after_arr = get_top_items_between_date(query, after_start_date, after_end_date, after_start_date) 
    #since this is a small list, it is ok to process the merge
    result_arr = Array.new([item_before_arr.length, item_after_arr.length].max){Hash.new}

    result_arr.each_with_index { |val, index|
      # index starts with 0, when displaying it as rank in UI, it should start with 1;  
      val['cvr_dropped_item_comparison_rank'] = index+1
      if (index < item_before_arr.length )
        val['item_id_before'] = item_before_arr[index]['item_id']
        val['item_title_before'] = item_before_arr[index]['title']
        val['image_url_before'] = item_before_arr[index]['image_url']
        val['seller_name_before'] = item_before_arr[index]['seller_name']
      end

      if (index < item_after_arr.length)
        val['item_id_after'] = item_after_arr[index]['item_id']
        val['item_title_after'] = item_after_arr[index]['title']
        val['image_url_after'] = item_after_arr[index]['image_url']
        val['seller_name_after'] = item_after_arr[index]['seller_name']
      end
    }
   return result_arr;
  end

  #input query: query 
  #input date_start: the starting date for one picked date range
  #input date_end: the end date for one picke date range
  #input query_date: specific date that is used to generate two week before and two week after, this is used to determin the seller_name
  # TODO: need to discuss with Hang, which date is the best to get the seller name
  #out put array of top 15 item from a query between date range
  def self.get_top_items_between_date(query, date_start, date_end, query_date)
    # result: query_items: "21630182,19423472,4764723,14237607,4764726,10992861, there is no related rank for that sequence.
    item_ids = find_by_sql(['select query_items from search_quality_daily where query_str= ?
      and query_date=(select max(query_date) from search_quality_daily where query_str=? and 
        query_date in (?))', query,query,date_start..date_end])
    if item_ids.length == 0
      return []
    end
      #process the result, split the string to array
    item_ids_arr=item_ids[0]['query_items'].split(",")
      #query item which id are in processed arr
    sql_statement = "select item_id, title, image_url, seller_name from
      (select item_id, title, image_url, seller_id 
       FROM all_item_attrs where item_id in (?)
      )a 
      inner join 
      (select distinct seller_id, seller_name from mp_seller_id_name_mapping_daily where data_date = ?
      )b
      on a.seller_id = b.seller_id"

      items = find_by_sql([sql_statement, item_ids_arr, query_date])
    return items
  end


  # this method is deprecated, but it is saved for performance improvement testing, don't remove now pls
  def self.get_cvr_dropped_query_slow(before_start_date,before_end_date,after_start_date,after_end_date,sum_count,page=1, limit=10)
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

    on b.query=d.query)f where diff>0.02 
order by diff desc;'

    before_date_arr=(before_start_date..before_end_date).map{ |date| date.strftime("%Y-%m-%d")}
    after_date_arr=(after_start_date..after_end_date).map{ |date| date.strftime("%Y-%m-%d")}

    result_data = find_by_sql([sqlStatement, before_date_arr, sum_count, after_date_arr, sum_count]) 
  end
end