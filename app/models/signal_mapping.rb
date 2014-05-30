class SignalMapping < BaseModel
  self.table_name = 'signal_mapping'
  
  def self.get_signals()
    cols = %q{signal_id, signal_name, enabled, section}
    where_str = %q{enabled = ?} 
    select(cols).where([where_str, 1]).order(
      %q{Field(section,'Relevance', 'Social', 'Customer Feedback', 'Miscellaneous')})
  end
end
