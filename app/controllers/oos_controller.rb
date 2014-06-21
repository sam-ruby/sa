class OosController < BaseController
  before_filter :set_common_data
  def get_trending
    query = params[:query]
    winning = (params[:winning].nil? or params[:winning].empty?) ? true :
      params[:winning] == 'true'
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
   
    get_total_entries = Proc.new do
      if query.nil? or query.empty?
        if params[:total_entries].nil? or 
          params[:total_entries].empty? or params[:total_entries].to_i <= 1
          total_entries = Oos.get_queries(
             winning, query_segment, cat_id, @date, 0).length
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
          Oos.get_queries(
            winning, query_segment, cat_id, @date, @page, @limit, @sort_by, @order)]
      }

      format.csv {
        render :json =>
          Oos.get_queries(
            winning, query_segment, cat_id, @date, 1, 4000)
      }
    end	
  end
end
