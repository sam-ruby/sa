class SearchController < BaseController

  before_filter :set_common_data
  def get_data
    query = params[:query]
    date = DateTime.parse(params[:query_date]) rescue DateTime.now
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
  
  def get_data
    query = params[:query]
    date = DateTime.parse(params[:query_date]) rescue DateTime.now
    query_stats = QueryCatMetricsDaily.get_week_average(query, before_end_date, before_start_date).first
    
    respond_to do |format|
      format.json do 
        render :json => query_stats
      end
    end
  end

  def get_query_stats_date
    query = params[:query]
    query_stats = QueryCatMetricsDaily.get_query_stats_date(
      query, @date)
    
    respond_to do |format|
      format.json do 
        render :json => query_stats
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
end
