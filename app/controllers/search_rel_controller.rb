class SearchRelController < BaseController

  before_filter :set_common_data

  def get_search_words
    week = get_week_from_date(@date)
    @search_words = SearchQualityDaily.get_query_stats(
      @year, week, @date, @page, @sort_by, @order, @limit)

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

  def get_query_items
    respond_to do |format|
      format.json do 
        render :json => get_items
      end
    end
  end
  
  def get_items
    query_str = params[:query]
    view = params[:view]
    result = []
    return result unless query_str
    
    if view == 'weekly'
      date = get_date_from_week(@week)
    else
      date = @date
    end
    query_dates = (date-7.days..date-1.days).to_a.map {|d|
      "'#{d.strftime('%Y-%m-%d')}'"}

    results = SearchQualityDaily.get_search_relevance_data_by_word(
      query_str, date)
    return result if results.empty?
    
    query_items = results.first['32_query_items']
    rev_ranks = results.first['rev_ranks']
    top_rev_items = results.first['top_rev_items']
    
    return result if query_items.nil? or top_rev_items.nil?
    query_items_list = query_items.split(',')[0..15]
    top_rev_items_list = top_rev_items.split(',')
    rev_ranks = rev_ranks.split(',')
    
    item_details = {}
    AllItemAttrs.get_item_details(query_str,
      (query_items_list + top_rev_items_list).uniq, date, query_dates).each do 
      |item| item_details[item.item_id] = item end

    index = 1
    query_items_list.zip(top_rev_items_list, rev_ranks) do |items|
      if item_details[items[0]].nil? 
        walmart_item = {:item_id => items[0],
                        :image_url => nil}
      else
        walmart_item = item_details[items[0]]
      end

      if item_details[items[1]].nil? 
        rev_item = {:item_id => items[1],
                    :image_url => nil}
      else
        rev_item = item_details[items[1]]
      end

      revenue = rev_item.item_revenue rescue 0
      result.push({:position => index,
                   :walmart_item => walmart_item,
                   :rev_based_item => rev_item,
                   :revenue => revenue,
                   :rev_rank => items[2].to_i + 1})
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

    @search_words = QueryPerformance.get_comp_analysis(
      query, @week, @year, fuzzy, @page, @sort_by, @order, @limit)
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
