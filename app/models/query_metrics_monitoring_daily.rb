# QueryMetricsMonitoring Model 
# @author Linghua Jin
# @since Dec, 2013
# This is the model for generating query metics monitoring daily
# Table maintained by Zhenrui Wang


class QueryMetricsMonitoring < BaseModel
  self.table_name = 'query_search_metrics_monitoring_daily_temp'
  def self.get_query_metrics_monitoring_daily(data_date, page = 1, limit = 10)

  	monitoring_data =  
  	selects = %q{query,count, pvr, atc, con, pvr,pvr_trend_score, atc_trend_score, con_trend_score, 
  	  pvr_ooc_score, atc_ooc_score, con_ooc_score}
  	QueryDroppingConversion.select(selects).where(%q{data_date = ?}, data_date)

  end