class SearchKPIController < BaseController 
  
  before_filter :set_common_data
  
  def get_data
    results = SearchKPI.get_data()
    respond_to do |format|
      format.json do
        render :json => {:unpaid => results.first, :paid => results.last}
      end
    end
  end
end
            
