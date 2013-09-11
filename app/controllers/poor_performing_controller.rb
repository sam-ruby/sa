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
    view = params['view']
    week = params[:week] || QueryPerformance.available_weeks.first[:week]
    if view == 'weekly'
      @walmart_items = ItemQueryCatMetricsWeekly.get_walmart_items(
        query, @cat_id, week, @year)
    else
      @walmart_items = ItemQueryCatMetricsDaily.get_walmart_items(
        query, @cat_id, @date)
    end
    
    respond_to do |format|
      format.json do 
        render :json => @walmart_items
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
    respond_to do |format|
      format.json do 
        result = URLMapping.get_amazon_items(query).map do |record|
          record.attributes.merge(:walmart_price => record.walmart_price)
        end
        render :json => result
      end
    end
  end
end
