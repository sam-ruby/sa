class SearchRelController < BaseController

  before_filter :set_common_data

  def get_search_words
    query = params[:query] 
    year_week = get_week_from_date(@date)
    week = year_week[:week]
    year = year_week[:year]

    respond_to do |format|
      format.json do 
        @search_words = SearchQualityDaily.get_query_stats(
          query, year, week, @date, @page, @limit, @sort_by, @order)
        if @search_words.nil? or @search_words.empty?
          render :json => [{:total_entries => 0}, @search_words]
        else
          render :json => [
            {:total_entries => 500, :date => @date}, @search_words]
        end
      end
      format.csv do |format|
        result = SearchQualityDaily.get_query_stats(
          query, year, week, @date, 1,10000).map do|record|
            {'Query String' => record.query,
             'Query Count' => record.query_count,
             'Rank Metric' => record.rank_metric.to_f.round(2),
             'Catalog Overlap' => record.cat_rate.to_f.round(2),
             'Results Shown in Search' => record.show_rate.to_f.round(2),
             'Overall Relevance Score' => record.rel_score.to_f.round(2), 
             'Conversion Rank Correlation' =>
                record.search_con_rank_correlation.to_f.round(2),
             'Query Revenue' => record.revenue,
             'Query Conversion' => record.query_con.to_f.round(2)}
          end
          render :json => result
      end
    end
  end

  def get_query_items
    respond_to do |format|
      format.json do 
        render :json => get_items
      end
      format.csv do 
        render :json => get_items(:csv)
      end
    end
  end
  
  def get_items(mode=:json)
    query_str = params[:query]
    view = params[:view]
    result = []
    return result unless query_str
    date = @date
    # query_dates = (date-28.days..date-1.days).to_a.map {|d|
    #  "'#{d.strftime('%Y-%m-%d')}'"}

    query_dates = (date-28.days..date-1.days).to_a
    results = SearchQualityDaily.get_search_relevance_data_by_word(
      query_str, date)
    return result if results.empty?
    
    query_items = results.first['32_query_items'].split(',')[0..15] rescue nil
    con_ranks = results.first['con_ranks'].split(',') rescue nil
    top_con_items = results.first['top_con_items'].split(',') rescue nil
    top_items_con = results.first['top_16_con'].split(',') rescue nil
    top_items_site_rev = results.first[
      'top_16_site_revenue'].split(',') rescue nil
    
    return result if query_items.nil? or top_con_items.nil?
   
    item_details = {}
    AllItemAttrs.get_item_details(query_str,
      (query_items + top_con_items).uniq, query_dates).each do 
      |item| item_details[item.item_id] = item 
    end

    index = 1
    query_items.zip(
      con_ranks, top_con_items, top_items_con, top_items_site_rev) do |items|
      if item_details[items[0]].nil? 
        walmart_item = {:item_id => items[0],
                        :image_url => nil}
      else
        walmart_item = item_details[items[0]]
      end

      if item_details[items[2]].nil? 
        con_item = {:item_id => items[2],
                    :image_url => nil}
      else
        con_item = item_details[items[2]]
      end

      con_rank = items[1].to_i + 1
      top_item_con = items[3].to_f
      w_oos_rate = walmart_item[:i_oos]
      c_oos_rate = con_item[:i_oos]

      if mode == :json
        result.push({:position => index,
                     :walmart_item => walmart_item,
                     :con_based_item => con_item,
                     :con => top_item_con,
                     :w_oos => w_oos_rate, 
                     :c_oos => c_oos_rate, 
                     :con_rank => con_rank})
      else
        result.push({'Position' => index,
                     'Walmart Item Id' => walmart_item[:item_id],
                     'Walmart Item Title' => walmart_item[:title],
                     'Con Rank' => con_rank,
                     'Walmart Item Image URL' => walmart_item[:image_url],
                     'Con Based Item Id' => con_item[:item_id],
                     'Con Based Item Title' => con_item[:title],
                     'Item Image URL' => con_item[:image_url],
                     'Out of Stock Rate' => walmart_item[:i_oos]})
      end
      index += 1
    end
    result
  end

  def get_comp_analysis
    query = params[:query]
    if params[:fuzzy]
      fuzzy = !params[:fuzzy].match(/true/i).nil?
    else
      fuzzy = false
    end
    year_week = get_week_from_date(@date)
    week = year_week[:week]
    year = year_week[:year]

    @search_words = QueryPerformance.get_comp_analysis(
      query, week, year, fuzzy, @page, @sort_by, @order, @limit)
    if @search_words.nil? or @search_words.empty?
      render :json => [{:total_entries => 0}, @search_words]
    else
      respond_to do |format|
        format.json do 
          render :json => [
            {:total_entries => @search_words.total_pages * @limit,
             :date => @date}, @search_words]
        end
      end
    end
  end
end
