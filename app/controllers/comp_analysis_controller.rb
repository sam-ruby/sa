class CompAnalysisController < BaseController
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
    respond_to do |format|
      format.json do 
        walmart_items = SearchQualityDaily.get_walmart_items(query, @date)
        render :json => walmart_items
      end
      format.csv do 
        walmart_items = SearchQualityDaily.get_walmart_items(
          query, @date).map do |record|
            {'Item Name' => record.title,
             'Item Image URL' => record.image_url,
             'Item Revenue' => record.item_revenue.to_f.round(2),
             'Item Shown Count' => record.shown_count,
             'Item Conversion' => record.item_con.to_f.round(2),
             'Item ATC' => record.item_atc.to_f.round(2),
             'Item PVR' => record.item_pvr.to_f.round(2)}
          end
        render :json => walmart_items
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

  def get_amazon_items
    query = params['query']
    week = params[:week] || get_available_weeks.first[:week]
    respond_to do |format|
      format.json do 
        render :json => URLMapping.get_amazon_items(
          query, ((week.to_i-3)..week.to_i).to_a, @year)
      end
    end
  end
end
