class ConvCorController < BaseController
  before_filter :set_common_data

  def get_distribution
    respond_to do |format|
      format.json { render :json => SearchQualityDaily.get_distribution(@date) }
    end		        
  end

  def get_winners
    query = params[:query]
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 3944
   
    if query.nil? or query.empty?
      if params[:total_entries].nil? or 
        params[:total_entries].empty? or params[:total_entries].to_i <= 1
        total_entries = SearchQualityDaily.get_daily_queries(
           query_segment, cat_id, @date, 0).length
      else
        total_entries = params[:total_entries].to_i
      end
    else
      total_entries = 1
    end

    respond_to do |format|
      format.json { render :json => [
        {total_entries: total_entries},
        SearchQualityDaily.get_daily_queries(
          query_segment, cat_id, @date, @page, @limit, @sort_by, @order)]}
    end	
  end
end
