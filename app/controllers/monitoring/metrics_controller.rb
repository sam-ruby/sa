class Monitoring::MetricsController < BaseController
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
        results = QueryMetricsMonitoring.get_query_metrics_monitoring_daily(
          nil, @date, 1,'con_rank_score' ,'desc', 10000).map do |record|
            {'Query' => record.query,
             'Count' => record.count,
             'Conversion' => record.con.to_f.round(2),
             'Conversion ooc Score' => record.con_ooc_score.to_f.round(2),
             'Conversion Trend Score' => record.con_trend_score.to_f.round(2),
             'Conversion Rank Score' => record.con_rank_score.to_f.round(2),
             'PVR' => record.pvr.to_f.round(2),
             'PVR ooc Score' => record.pvr_ooc_score.to_f.round(2),
             'PVR Trend Score' => record.pvr_trend_score.to_f.round(2),
             'PVR Rank Score' => record.pvr_rank_score.to_f.round(2),
             'ATC' => record.atc.to_f.round(2),
             'ATC ooc Score' => record.atc_ooc_score.to_f.round(2),
             'ATC Trend Score' => record.atc_trend_score.to_f.round(2),
             'ATC Rank Score' => record.atc_rank_score.to_f.round(2)
           }
          end
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
        render :json => results
      end
    end
  end

end
