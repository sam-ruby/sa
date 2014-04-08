class SummaryMetrics < BaseModel
  self.table_name = 'segmentation_summary_metrics_daily'
 
  def self.get_metrics(segment, cat_id, date)
    cols = %q{metrics_name, value, losers, ucl, lcl}
    
    where_str = %q{cat_id in (-1, ?) and data_date in (?, ?) and 
    segmentation in (?, ?)}

    select(cols).where(
      [where_str, cat_id, date, date - 1.day, segment, 'ALL QUERIES']).order(
      'metrics_name, data_date desc') 
  end
end
