class SearchController < BaseController

  before_filter :set_common_data
  def get_data
    query = params[:query]
    date = DateTime.parse(params[:query_date]) rescue DateTime.now
    days_range = params[:selected_week] ? Integer(params[:selected_week]) * 7 :
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
end
