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
        results = URLMapping.get_amazon_items(
          query, ((week.to_i-3)..week.to_i).to_a, @year)[:all_items].map do|record|
            {'Amazon Position' => record.position,
             'Item Name' => record.name,
             'Amazon Item image URL' => record.img_url,
             'Amazon Item URL' => record.url,
             'Amazon Item ID' => record.idd,
             'Walmart Position' => record.walmart_position,
             'Brand' => record.brand,
             'Amazon Price' => record.newprice.to_f.round(2),
             'Walmart Price' => record.curr_item_price.to_f.round(2)}
          end
        render :json => results
      end
    end
  end
end
