class QueryPerformanceWeek < BaseModel
  self.table_name = 'query_performance_week'
  
  def self.get_comp_analysis(
    query, week, year, fuzzy=false, page=1,
    order_col='id', order='asc', limit=10)
   
    order_str = order_col.nil? ? nil :
     order.nil? ? order_col : order_col + ' ' + order  
    select_cols = %q{distinct query as query, cat_rate as catalog_overlap,
    show_rate as results_shown_in_search, rel_score as overall_relevance_score}
  
    if query.nil? || query.empty?
      select(select_cols).where(%q{week=? and year=? and cat_rate>0.5 and 
        show_rate<0.5 and rel_score is not null}, week, year).order(
          order_str).page(page).per(limit)
    elsif !fuzzy
      select(select_cols).where(%q{week=? and year=? and cat_rate>0.5 and 
        show_rate<0.5 and rel_score is not null and query = ?},
        week, year, query).order(order_str).page(page).per(limit)
    elsif fuzzy
      select(select_cols).where(%q{week=? and year=? and cat_rate>0.5 and 
        show_rate<0.5 and rel_score is not null and query like ?},
        week, year, "%#{query}%").order(order_str).page(page).per(limit)
    end
  end
  
  def self.available_weeks
    QueryPerformance.select('distinct week, year').order('year desc,week desc').map {|x|
      {week: x.week, year: x.year}}
  end
end
