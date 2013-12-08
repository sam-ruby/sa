class SearchController < BaseController

  before_filter :set_common_data
  def get_data
    query = params[:query]
    date = DateTime.strptime(params[:query_date], '%m-%d-%Y') rescue DateTime.now
    days_range = params[:weeks_apart] ? Integer(params[:weeks_apart]) * 7 :
      7
    before_start_date = date - 1.day
    after_start_date = date + 1.day

    before_end_date = before_start_date - days_range.days
    before_week = QueryCatMetricsDaily.get_week_average(
      query, before_end_date, before_start_date).first
    before_title = "#{before_end_date.strftime('%b %d, %Y')} - " + 
      "#{before_start_date.strftime('%b %d, %Y')}"
   
    after_end_date = after_start_date + days_range.days
    after_week = QueryCatMetricsDaily.get_week_average(
      query, after_start_date, after_end_date).first
    after_title = "#{after_start_date.strftime('%b %d, %Y')} - " +
      "#{after_end_date.strftime('%b %d, %Y')}"
 
    user_id = 101
    QuerySearchList.store_query_words(
      user_id, query, params[:query_date], params[:weeks_apart])
    
    respond_to do |format|
      format.json do 
        render :json => {
          :before_week => {
            :error => before_week.query_count.nil? ? 1 : 0,
            :data => before_week,
            :title => before_title},
          :after_week => {
            :error => after_week.query_count.nil? ? 1 : 0,
            :data => after_week,
            :title => after_title}}
      end
    end
  end
  
  def get_query_stats_date
    query = params[:query]
    
    respond_to do |format|
      format.json do 
        query_stats = QueryCatMetricsDaily.get_query_stats_date(
          query, @year, get_week_from_date(@date), @date, 
          @page, @sort_by, @order, @limit)
        p 'query_stats', query_stats.total_pages, query_stats
        if query_stats.nil? or query_stats.empty?
          render :json => [{:total_entries => 0}, query_stats]
        else
          render :json => [
            {:total_entries => query_stats.total_pages * @limit,
             :date => @date}, query_stats]
        end
      end
      
      format.csv do
        render :json => QueryCatMetricsDaily.get_query_stats_date(
          query, @year, get_week_from_date(@date), @date, 0)
      end
    end
  end

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
    p "controller called get_cvr_dropped_query params", params.to_yaml
    query_date = DateTime.strptime(params[:query_date], "%m-%d-%Y") rescue DateTime.now
    query_date = query_date.strftime("%Y-%m-%d")
    #by_default, set to two week apart
    weeks_apart = params[:weeks_apart] ? Integer(params[:weeks_apart]) : 2
    respond_to do |format|
      format.json do 
        result= QueryDroppingConversion.get_cvr_dropped_query(weeks_apart,query_date,@page,@limit)
          render :json => [
            {:total_entries => result.total_pages * @limit,
             :date => @date}, result]
      end
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
    p 'before_start_date', before_start_date

    respond_to do |format|
      format.json do 
        @cvr_dropped_query_item_comparison = QueryDroppingConversion.get_cvr_dropped_query_item_comparisons(query, before_start_date,before_end_date,after_start_date,after_end_date)
        render :json => @cvr_dropped_query_item_comparison
      end
    end
  end

  # deprecated, save for caching performance testing, don't remove pls
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
        p 'result', result.length, result;
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
