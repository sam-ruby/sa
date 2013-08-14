class SearchQualityDailyController < BaseController

  before_filter :set_common_data

  def get_search_words
    @date = params['date'] || '2013-08-05'
    @search_words = SearchQualityDaily.get_search_relevance_data(
      @date, @page, @sort_by, @order, @limit)
    if @search_words.nil? or @search_words.empty?
      render :json => [{:total_entries => 0}, @search_words]
    else
      respond_to do |format|
        format.json do 
          render :json => [
            {:total_entries => @search_words.total_pages * @limit},
            @search_words]
        end
      end
    end
  end
end
