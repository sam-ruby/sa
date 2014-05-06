class SignalComparisonController < BaseController
  before_filter :set_common_data
  def get_signals
    query = params[:query]
    items = params[:items]
    rel_items = nil
    ideal_items = nil
   
    respond_to do |format|
      format.json { 
        item_position_details = SearchQualityDailyV2.get_search_relevance_data_by_word(query, @date)
        unless item_position_details.nil?
          rel_items = JSON.parse(
            item_position_details.first.rel_item_rank_json) rescue nil
          ideal_items = JSON.parse(
            item_position_details.first.ideal_items_not_in_top16_json) rescue nil
        end
          
        results = SignalComparison.get_signals(
          query, items.split(/,/), @date)
        
        results = results.map do |record|
          t_results = nil
          record.signals_json = JSON.parse(record.signals_json) rescue nil
          unless rel_items.nil?
            rel_items.each do |position, item_details|
              if item_details['item_id'].to_i == record.item_id.to_i
                t_results = record.attributes.merge(
                  {position: position,
                   orders: item_details['orders'],
                   in_top_16: 1})
              end
            end
          end
          
          unless ideal_items.nil?
            ideal_items.each do |position, item_details|
              if item_details['item_id'].to_i == record.item_id.to_i
                position = position.split('_').first
                t_results = record.attributes.merge(
                  {orders: item_details['orders'],
                   position: position,
                   in_top_16: 0})
              end
            end
          end
          t_results || record.attributes
        end
        render :json => results
      }
    end	
  end
end
