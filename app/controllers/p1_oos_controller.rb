class P1OosController < BaseController
  before_filter :set_common_data
  def get_trending
    query = params[:query]
    winning = (params[:winning].nil? or params[:winning].empty?) ? true :
      params[:winning] == 'true'
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
   
    if query.nil? or query.empty?
      if params[:total_entries].nil? or 
        params[:total_entries].empty? or params[:total_entries].to_i <= 1
        total_entries = P1Oos.get_queries(
           winning, query_segment, cat_id, @date, 0).length
      else
        total_entries = params[:total_entries].to_i
      end
    else
      total_entries = 1
    end

    respond_to do |format|
      format.json { render :json => [
        {total_entries: total_entries},
        P1Oos.get_queries(winning,
          query_segment, cat_id, @date, @page, @limit, @sort_by, @order)]}
    end	
  end
end
