class SearchKPI < BaseModel
  self.table_name = 'search_kpis'

  def self.get_data(range_in_days=365)
    select = %q{unix_timestamp(date) * 1000 as date, is_paid, traffic as query_count,
      product_view_rate as query_pvr, add_to_cart_rate as query_atc,
      conversion_rate as query_con} 
    
    unpaid = where(
      {:is_paid=>0, :date=>(Time.now - range_in_days.days)..Time.now}
    ).select(select).order("date ASC")
                            
    paid = where(
      {:is_paid=>1, :date=>(Time.now - range_in_days.days)..Time.now}
    ).select(select).order("date ASC")
    
    [unpaid, paid]
  end
end
