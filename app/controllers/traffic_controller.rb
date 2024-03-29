class TrafficController < BaseController
  before_filter :set_common_data

  def get_distribution
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
    respond_to do |format|
      format.json { render :json => Traffic.get_distribution(
        query_segment, cat_id, @date) }
    end		        
  end
  
  def get_stats
    cat_id = params[:cat_id] || 0
    query_segment = params[:query_segment]
    respond_to do |format|
      format.json { render :json => Traffic.get_stats(
        query_segment, cat_id) }
    end		        
  end

  def get_trending
    query = params[:query]
    user_id = params[:user_id]
    filter_by = params[:filter_by]
    filter_cond = params[:filter_cond]
    winning = (params[:winning].nil? or params[:winning].empty?) ? true :
      params[:winning] == 'true'
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
  
    get_total_entries = Proc.new do
      if query.nil? or query.empty?
        if params[:total_entries].nil? or 
          params[:total_entries].empty? or params[:total_entries].to_i <= 1
          total_entries = Traffic.get_queries(
             winning, query_segment, cat_id, @date, 
             filter_by, filter_cond, user_id, 0).length
        else
          total_entries = params[:total_entries].to_i
        end
      else
        total_entries = 1
      end
      puts 'Got total entries ', total_entries
      total_entries
    end

    respond_to do |format|
      format.json {
        render :json => [
          {total_entries: get_total_entries.call()},
          Traffic.get_queries(
            winning, query_segment, cat_id, @date, filter_by,
            filter_cond, user_id, @page, @limit, @sort_by, @order)]
      }
      
      format.csv {
        render :json => Traffic.get_queries(
          winning, query_segment, cat_id, @date, filter_by, 
          filter_cond, user_id, 1, 4000)
      }
    end	
  end
end
