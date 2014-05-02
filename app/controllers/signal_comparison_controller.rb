class SignalComparisonController < BaseController
  before_filter :set_common_data
  def get_signals
    query = params[:query]
    items = params[:items]
   
    respond_to do |format|
      format.json { 
        render :json => (SignalComparison.get_signals(
          query, items.split(/,/), @date).map do |record|
            record.signals_json = JSON.parse(record.signals_json) rescue nil
            rel_details = JSON.parse(record.rel_details) rescue nil
            item_position = nil
            unless rel_details.nil?
              rel_details.each do |position, item_details|
                if details.item_id == record.item_id
                  return record.attributes.merge({position: position})
                end
              end
            end
            record.attributes
          end)
      }
    end	
  end
end
