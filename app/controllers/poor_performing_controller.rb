class PoorPerformingController < BaseController

  before_filter :set_common_data

  def get_search_words
    @search_words = QueryCatMetricsDaily.get_search_words(
      @date, @cat_id, @page, @sort_by, @order, @limit)
      
    respond_to do |format|
      format.json do 
      if @search_words.nil? or @search_words.empty?
        render :json => [{:total_entries => 0}, @search_words]
      else
        render :json => [
            {:total_entries => @search_words.total_pages * @limit},
            @search_words]
        end
      end
    end
  end
  
  def get_walmart_items
    query = params['query']
    @walmart_items = ItemQueryCatMetricsDaily.get_walmart_items(
      query, @cat_id, @date)
      
    respond_to do |format|
      format.json do 
        if @walmart_items.nil? or @walmart_items.empty?
          render :json => []
        else
          render :json => @walmart_items
        end
      end
    end
  end
end
