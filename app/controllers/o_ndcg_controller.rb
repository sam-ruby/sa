class ONdcgController < BaseController
  before_filter :set_common_data
  def get_trending
    query = params[:query]
    metrics_name = params[:metrics_name]
    winning = (params[:winning].nil? or params[:winning].empty?) ? true :
      params[:winning] == 'true'
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
   
    get_total_entries = Proc.new do
      if query.nil? or query.empty?
        if params[:total_entries].nil? or 
          params[:total_entries].empty? or params[:total_entries].to_i <= 1
          total_entries = ONdcg.get_queries(
             winning, query_segment, cat_id, @date, metrics_name, 0).length
        else
          total_entries = params[:total_entries].to_i
        end
      else
        total_entries = 1
      end
    end

    respond_to do |format|
      format.json {
        render :json => [
          {total_entries: get_total_entries.call()},
          ONdcg.get_queries(
            winning, query_segment, cat_id, @date, metrics_name,
            @page, @limit, @sort_by, @order)]
      }
      
      format.csv {
        render :json => ONdcg.get_queries(
          winning, query_segment, cat_id, @date, metrics_name,
          1, 4000)
      }
    end	
  end
end
