class SearchRelController < BaseController

  before_filter :set_common_data

  def get_search_words
    @search_words = SearchQualityDaily.get_search_relevance_data(
      @date, @page, @sort_by, @order, @limit)
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
    id = params[:id]
    query_str = params[:query_str]
    query_items = params[:query_items]
    top_rev_items = params[:top_rev_items]
    query = ''
    
    if query_str
      results = SearchQualityDaily.get_search_relevance_data_by_word(
        query_str, @date)
    elsif query_items.nil?  or top_rev_items.nil? or 
        query_items.empty? or top_rev_items.empty?
      results = SearchQualityDaily.get_search_relevance_data_by_id(id)
      unless results.empty?
        query_items = results.first['query_items']
        top_rev_items = results.first['top_rev_items']
        query = results.first['query_str']
      end
    end
    
    return render :nothing => true if query_items.nil? or top_rev_items.nil?
    
    query_items_list = query_items.split(',')
    top_rev_items_list = top_rev_items.split(',')

    item_details = {}
    AllItemAttrs.get_item_details(
      (query_items_list + top_rev_items_list).uniq).each do |item|
        item_details[item.item_id] = item
      end
    result = []
    query_items_list.zip(top_rev_items_list) do |items|
      result.push({:walmart_item => item_details[items[0]],
                   :rev_based_item => item_details[items[1]]})
    end
    
    respond_to do |format|
      format.json do 
        render :json => {:query=>query, :results=>result}
      end
    end
  end

  def get_comp_analysis
    week = params[:week] || QueryPerformance.available_weeks.first[:week]
    query = params[:query]
    @search_words = QueryPerformance.get_comp_analysis(
      query, week, @year, @page, @sort_by, @order, @limit)
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
