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
            record.attributes
          end)
      }
    end	
  end
end
