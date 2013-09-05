class QueryPerformance < BaseModel
  self.table_name = 'query_performance'
  
  def self.get_comp_analysis(
    week, year, page=1, order_col='id', order='asc', limit=10)
   
    order_str = order_col.nil? ? nil :
     order.nil? ? order_col : order_col + ' ' + order  
    select_cols = %q{distinct query_str as query, cat_rate as catalog_overlap,
    show_rate as results_shown_in_search, rel_score as overall_relevance_score}
   
    select(select_cols).where(%q{week=? and year=? and cat_rate>0.5 and 
      show_rate<0.5 and rel_score is not null}, week, year).order(
        order_str).page(page).per(limit)
  end
end
