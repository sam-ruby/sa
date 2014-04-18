class SummaryMetrics < BaseModel
  self.table_name = 'segmentation_summary_metrics_daily'
 
  def self.get_metrics(segment, cat_id, date, last_date)
    cols = %q{metrics_name, value, losers, ucl, lcl, data_date}
    
    where_str = %q{cat_id in (-1, ?) and data_date in (?, ?) and 
    segmentation in (?, ?)}

    select(cols).where(
      [where_str, cat_id, date, last_date, segment, 'ALL QUERIES']).order(
      'metrics_name, data_date desc') 
  end

  def self.get_stats(metrics_name, query_segment, cat_id)
    select(%q{unix_timestamp(data_date) * 1000 data_date,
           value score}).where(
      metrics_name: metrics_name,
      segmentation: query_segment, cat_id: cat_id).order(:data_date)
  end
end
