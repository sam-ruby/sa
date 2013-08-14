class QueryItemsController < BaseController

  before_filter :set_common_data

  def get_items
    @date = '2013-08-05'
    id = params[:id]
    query_items = params[:query_items]
    top_rev_items = params[:top_rev_items]
    
    if query_items.nil?  or top_rev_items.nil? or 
      query_items.empty? or top_rev_items.empty?
      results = SearchQualityDaily.get_search_relevance_data_by_id(id)
      unless results.empty?
        query_items = results.first['query_items']
        top_rev_items = results.first['top_rev_items']
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
    
    if result.empty?
      render :nothing=>true
    else
      respond_to do |format|
        format.json do 
          render :json => result
        end
      end
    end
  end
end
