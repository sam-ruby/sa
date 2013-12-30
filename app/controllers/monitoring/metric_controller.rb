class Monitoring::MetricController < BaseController
  before_filter :set_common_data
  
  def get_metric_monitor_table_data
    query = params[:query]
    respond_to do |format|
      format.json do 
        results = QueryMetricsMonitoring.get_query_metrics_monitoring_daily(
          query, @date, @page, @sort_by, @order, @limit)
        if results.nil? or results.empty?
          render :json => [{:total_entries => 0}, results]
        else
          render :json => [
            {:total_entries => results.total_pages * @limit,
             :date => @date}, results]
        end
      end
      format.csv do
        p "request csv"
        # if it is getting the csv file, set page to 1 and limit to 10000.(currently the max available is 500)
        results = QueryCountSpcDaily.get_words(
          nil, @date, 1,'con_rank_score' ,'desc', 10000)
        # .map do |record|
        #     {'Query' => record.query_str,
        #      'Query Score' => record.query_score.to_f.round(2),
        #      'Count' => record.query_count,
        #      'Conversion' => record.query_con.to_f.round(2)}
          # end
          render :json => results 
      end
    end
  end

  def get_query_stats
    query = params['query']
    type = params['stats_type']
    respond_to do |format|
      format.json do
        results = QueryMetricsMonitoring.get_query_stats(query, type)
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
