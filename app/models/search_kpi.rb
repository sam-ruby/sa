class SearchKPI < BaseModel
  self.table_name = 'search_kpis'

  def self.get_data(range_in_days=365)
    select = %q{unix_timestamp(data_date) * 1000 as date, is_paid, 
    traffic query_count, product_view_rate query_pvr, add_to_cart_rate query_atc,
    conversion_rate query_con} 
    
    unpaid = where(
      {:is_paid=>0, :data_date=>(Time.now - range_in_days.days)..Time.now}
    ).select(select).order("data_date ASC")
                            
    paid = where(
      {:is_paid=>1, :data_date=>(Time.now - range_in_days.days)..Time.now}
    ).select(select).order("data_date ASC")
    
    [unpaid, paid]
  end
end
