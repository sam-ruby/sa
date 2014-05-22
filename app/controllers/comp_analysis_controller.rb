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
    view = params['view']
    debugger

    respond_to do |format|
      if view =='ranged'
        start_date = DateTime.strptime(params[:start_date], "%m-%d-%Y")  
        end_date = DateTime.strptime(params[:end_date], "%m-%d-%Y")  
        walmart_items = ItemQueryMetricsDaily.get_walmart_items_over_time(
          query, start_date, end_date)
      else
        walmart_items = SearchQualityDailyV2.get_walmart_items_daily(query, @date)
      end
      format.json do 
        render :json => walmart_items
      end

      format.csv do       
        results = walmart_items.map do |record|
            {'Item Name' => record.title,
             'Item Image URL' => record.image_url,
             'Item Revenue' => record.revenue.to_f.round(2),
             'Item Shown Count' => record.shown_count,
             'Item Conversion' => record.i_con.to_f.round(2),
             'Item ATC' => record.i_atc.to_f.round(2),
             'Item PVR' => record.i_pvr.to_f.round(2)}
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

  def get_amazon_items
    query = params['query']
    view = params['view']
    four_weeks_info = get_four_weeks_from_date(@date)
    respond_to do |format|
      format.json do
        render :json => URLMapping.get_amazon_items(
          query, four_weeks_info)
      end
      format.csv do 
        results = URLMapping.get_amazon_items(
          query, four_weeks_info)[:all_items].map do|record|
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
