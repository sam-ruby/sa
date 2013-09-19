class SearchController < BaseController

  before_filter :set_common_data
  def get_data
    query = params[:query]
    date = DateTime.parse(params[:search_date]) rescue DateTime.now
   
    before_date_a = date - 8.days
    before_date_b = date - 1.day
    before_week = QueryCatMetricsDaily.get_week_average(
      query, before_date_a, before_date_b).first
    before_title = "#{before_date_a.strftime('%b %d, %Y')} - " + 
      "#{before_date_b.strftime('%b %d, %Y')}"
   
    after_date_a = date + 1.day
    after_date_b = date + 8.days
    after_week = QueryCatMetricsDaily.get_week_average(
      query, after_date_a, after_date_b).first
    after_title = "#{after_date_a.strftime('%b %d, %Y')} - " +
      "#{after_date_b.strftime('%b %d, %Y')}"
    
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
