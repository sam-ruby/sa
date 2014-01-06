class SearchController < BaseController

  before_filter :set_common_data
  def get_query_stats_date
    query = params[:query]
    week = get_week_from_date(@date)["week"]
    year = get_week_from_date(@date)["year"]
    
    respond_to do |format|
      format.json do 
        query_stats = QueryCatMetricsDaily.get_query_stats_date(
          query, year, week, @date, 
          @page, @sort_by, @order, @limit)

        if query_stats.nil? or query_stats.empty?
          render :json => [{:total_entries => 0}, query_stats]
        else
          render :json => [
            {:total_entries => query_stats.total_pages * @limit,
             :date => @date}, query_stats]
        end
      end
      
      format.csv do
        results = QueryCatMetricsDaily.get_query_stats_date(
          query, year, week, @date, 0).map do |record|
            {'Query' => record.query,
             'Catalog Overlap' => record.cat_rate.to_f.round(2),
             'Results Shown in Search' => record.show_rate.to_f.round(2),
             'Overall Relevance Score' => record.rel_score.to_f.round(2),
             'Rev Rank Correlation' => record.search_rev_rank_correlation.to_f.round(2),
             'Revenue' => record.query_revenue.to_f.round(2),
             'Count' => record.query_count}
          end
        render :json => results
      end
    end
  end
 
 # this is deprecated
  def get_recent_searches
    result = QuerySearchList.get_query_words(101).sort do |a,b|
      b['created_at'] <=> a['created_at']
    end
    respond_to do |format|
      format.json do 
        render :json => result
      end
    end
  end

  def get_cvr_dropped_query
    query_date = DateTime.strptime(params[:query_date], "%m-%d-%Y") rescue DateTime.now
    #by_default, set to two week apart
    weeks_apart = params[:weeks_apart] ? Integer(params[:weeks_apart]) : 2
    query = params[:query]
    respond_to do |format|
      format.json do
        #based on input, if there is no query param, get top 500, else do search 
        if query.nil? or query.empty?
          result= QueryDroppingConversion.get_cvr_dropped_query_top_500(weeks_apart,query_date,@sort_by,@order,@page,@limit)
          render :json => [{:total_entries => result.total_pages * @limit, :date => @date}, result]
        else
          result= QueryDroppingConversion.get_cvr_dropped_query_with_query(query, weeks_apart,query_date,@page,@limit)
          render :json => [{:total_entries => 1, :date => @date}, result]
        end
      end
      # since we know there are always total 500 entries. 
      format.csv do
        results = []
        if query.nil? or query.empty?
          results= QueryDroppingConversion.get_cvr_dropped_query_top_500(
            weeks_apart,query_date, 1, 500)
        else
          results= QueryDroppingConversion.get_cvr_dropped_query_with_query(query, weeks_apart,query_date,@page,@limit)
        end

        results = results.map do |record|
          {'Query' => record.query,
           'Rank' => record.rank,
           'Query Conversion Difference' => record.query_con_diff,
           'Query Conversion Before' => record.query_con_before,
           'Query Conversion After' => record.query_con_after,
           'Query Count Before' => record.query_count_before,
           'Query Count After' => record.query_count_after,
           'Query Revenue Before' =>record.query_revenue_before,
           'Query Revenue After' => record.query_revenue_after,
           'Potential Revenue Loss'=> record.expected_revenue_diff
          }
        end
        render :json => results
      end
      #end_format_csv
    end
  end

  def get_cvr_dropped_query_item_comparison
    date = DateTime.strptime(params[:query_date], "%m-%d-%Y") rescue DateTime.now
    days_range = params[:weeks_apart] ? Integer(params[:weeks_apart]) * 7 : 7
    query = params[:query]
    before_start_date = date-1.day-days_range+1.day
    before_end_date = date-1.day
    after_start_date = date
    after_end_date = date + days_range-1.day

    respond_to do |format|
      format.json do 
        results = QueryDroppingConversion.get_cvr_dropped_query_item_comparisons(query, before_start_date,before_end_date,after_start_date,after_end_date)
        render :json => results
      end

      format.csv do 
        results = QueryDroppingConversion.get_cvr_dropped_query_item_comparisons(query, before_start_date,before_end_date,after_start_date,after_end_date)
        results =  results.map do |record|
          # see QueryDroppingConversion.get_cvr_dropped_query_item_comparisons when it is returned, it returned array of 
          # hash instead of array of objects 
          {'Rank' => record["cvr_dropped_item_comparison_rank"],
           'Item Id Before' => record["item_id_before"],
           'Item Title Before' => record["item_title_before"],
           'Seller Before' => record["seller_name_before"],
           'Item Id After' => record["item_id_after"],
           'Item Title After' => record["item_title_after"],
           'Seller After' => record["seller_name_after"]
          }
        end
        render :json => results
      end
    end
  end

  # deprecated, save for caching performance testing, don't remove pls. -ljin
 def get_cvr_dropped_query_slow
    p "controller called get_cvr_dropped_query params", params.to_yaml
    date = DateTime.strptime(params[:query_date], "%m-%d-%Y") rescue DateTime.now
    days_range = params[:weeks_apart] ? Integer(params[:weeks_apart]) * 7 : 7
    sum_count = params[:sum_count] ? Integer(params[:sum_count]) : 5000
    p "controller sum_count", sum_count
    p "query_date", date
    p "days_range", days_range
    before_start_date = date-1.day-days_range+1.day
    before_end_date = date-1.day
    after_start_date = date
    after_end_date = date + days_range-1.day   
    respond_to do |format|
      format.json do 
        result= QueryCatMetricsDaily.get_cvr_dropped_query(before_start_date,before_end_date,after_start_date,after_end_date,sum_count,@page,@limit)
        p 'result', result.length, result
        p @page, @limit

        start_index = @limit * @page - @limit
        end_index = start_index + @limit -1
        if result.nil? or result.empty?
          render :json => [{:total_entries => 0}, result]
        else
        render :json => [
            {:total_entries => result.length,
             :date => @date, :sum_count => sum_count}, result[start_index..end_index]]
        end
      end
    end
  end
  #end of function get_cvr_dropped_query_slow
end
