class AllItemAttrs < BaseModel
  self.table_name = 'all_item_attrs'

  def self.get_item_details(item_id_list)
    self.where('item_id in (?)', item_id_list)
  end
end
