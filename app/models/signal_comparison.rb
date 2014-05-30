class SignalComparison < BaseModel
  self.table_name = 'query_item_rel_signals_daily'
  
  def self.get_signals(query, item_ids, data_date)
    cols = %q{a.query, b.item_id, a.signals_json, b.image_url, b.title}

    join_str = %Q{as b left outer join query_item_rel_signals_daily a on
      a.item_id = b.item_id and a.data_date = '#{data_date}' 
      and a.query = '#{query}'}
    
    where_str = %q{b.item_id in (?)} 
    select(cols).from('all_item_attrs').joins(join_str).where(
      [where_str, item_ids])
  end
end
