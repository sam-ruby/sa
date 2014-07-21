class JobMonitoring
  def self.check_segmentation_summary(date)
    results = SummaryMetrics.where(
      {cat_id: 0, :segmentation => 'TOP QUERIES',
       :metrics_name => :traffic,
       data_date: date})
    results.size > 0 ? true : false
  end

  def self.pipeline_log_daily(date)
    results = PipelineLogDaily.where(
      {data_date: date, process: 'Query_Categorization_Daily', status: 1})
    results.size > 0 ? true : false
  end
  
  def self.data_validation(date)
    results = PipelineLogDaily.where(
      {data_date: date, process: 'data_validation', status: 1})
    results.size > 0 ? true : false
  end
  
  def self.pipeline_log_weekly(week, year)
    results = PipelineLogWeekly.where(
      {week: week, year: year, status: 1, process: 'Trending_Items'})
    results.size > 0 ? true : false
  end
end
