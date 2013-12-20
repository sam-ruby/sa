class Monitoring::MetricController < BaseController
  before_filter :set_common_data
  
  def get_metric_monitor_table_data
    query = params[:query]
    respond_to do |format|
      format.json do 
        results = QueryMetricsMonitoring.get_query_metrics_monitoring_daily(
          @date, @page, @limit)

        render :json => [
            {:total_entries => results.total_pages * @limit,
             :date => @date}, results]
   
        # if query_words.nil? or query_words.empty?
        #   render :json => [{:total_entries => 0}, query_words]
        # else
        #   render :json => [
        #     {:total_entries => query_words.total_pages * @limit,
        #      :date => @date}, query_words]
        # end
      end
      # format.csv do
      #   results = QueryCountSpcDaily.get_words(
      #     query, @date, 0).map do |record|
      #       {'Query' => record.query_str,
      #        'Query Score' => record.query_score.to_f.round(2),
      #        'Count' => record.query_count,
      #        'Conversion' => record.query_con.to_f.round(2)}
      #     end
      #     render :json => results 
      # end
    end
  end

  def get_query_stats
    query = params['query']
    type = "atc"
    respond_to do |format|
      format.json do
        results = QueryMetricsMonitoring.get_query_stats(query)
        # baseline_stats = QueryCountDailyBaseline.get_query_stats(query, @date)
        render :json => results
      end
    end
  end
  
  # def get_query_stats
  #   query = params['query']
  #   respond_to do |format|
  #     format.json do
  #       baseline_stats = QueryCountDailyBaseline.get_query_stats(query, @date)
  #       render :json => {
  #         :stats => QueryCatMetricsDaily.get_query_stats(query),
  #         :baseline_mean => baseline_stats.first[:baseline_mean],
  #         :baseline_lcl => baseline_stats.first[:baseline_lcl],
  #         :baseline_ucl => baseline_stats.first[:baseline_ucl]}
  #     end
  #   end
  # end
end
