class QueryCountDailyBaseline < BaseModel
  self.table_name = 'query_count_daily_baseline'

  def self.get_query_stats(query, date)
    selects = %q{baseline_mean, baseline_lcl, baseline_ucl}
    
    select(selects).where(
    [%q{query_str = ? AND baseline_est <= ?}, query, date]).order(
      "baseline_est desc").limit(1)
  end
end
