class PoorPerformingController < BaseController
  before_filter :set_common_data
  def get_search_words
    @search_words = QueryCatMetricsDaily.get_search_words(
      @date, @page, @sort_by, @order, @limit)
      
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
    if view == 'weekly'
      @walmart_items = ItemQueryCatMetricsWeekly.get_walmart_items(
        query, @cat_id, week, @year)
    else
      @walmart_items = SearchQualityDaily.get_walmart_items(
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
    view = params['view']
    if view == 'daily'
      week = get_week_from_date(@date)
    else
      week = @week
    end
    respond_to do |format|
      format.json do 
        render :json => URLMapping.get_amazon_items(
          query, ((week.to_i-3)..week.to_i).to_a, @year)
      end

      format.csv do 
        render :json => URLMapping.get_amazon_items(
          query, ((week.to_i-3)..week.to_i).to_a, @year)[:all_items]
      end
    end
  end
end
