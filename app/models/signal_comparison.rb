class SignalComparison < BaseModel
  self.table_name = 'query_item_rel_signals_daily'
  
  def self.get_signals(query, item_ids, data_date)
    cols = %q{a.query, a.item_id, a.signals_json, b.image_url, b.title}

    join_str = %q{as a, all_item_attrs as b}
    
    where_str = %q{a.item_id = b.item_id and a.data_date = ? and 
      a.query = ? and a.item_id in (?)} 
    
    select(cols).joins(join_str).where([where_str, data_date, query, item_ids])
  end
end
