class PoorPerformingController < BaseController
  before_filter :set_common_data
  
  def get_search_words
    query = params[:query]
    respond_to do |format|
      format.json do 
        @search_words = QueryCatMetricsDaily.get_search_words(
          query, @date, @page, @sort_by, @order, @limit)
        if @search_words.nil? or @search_words.empty?
          render :json => [{:total_entries => 0}, @search_words]
        else
          render :json => [
              {:total_entries => @search_words.total_pages * @limit},
              @search_words]
        end
      end
      format.csv do
        results = QueryCatMetricsDaily.get_search_words(
          query, @date, 0).map do |record|
            {'Query' => record.query,
             'Query Revenue' => record.query_revenue.to_f.round(2),
             'Conversion' => record.query_con.to_f.round(2),
             'ATC' => record.query_atc.to_f.round(2),
             'PVR' => record.query_pvr.to_f.round(2)}
          end
        render :json => results
      end
    end
  end
  
  def get_query_stats
    query = params['query']
    respond_to do |format|
      format.json do 
        render :json => QueryCatMetricsDaily.get_query_stats(query)
      end
    end
  end

end
