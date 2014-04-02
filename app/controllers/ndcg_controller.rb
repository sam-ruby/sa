class NdcgController < BaseController
  before_filter :set_common_data

  def get_distribution
    respond_to do |format|
      format.json { render :json => Ndcg.get_distribution(@date) }
    end		        
  end

  def get_queries(winning)
    query = params[:query]
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 3944
   
    if query.nil? or query.empty?
      if params[:total_entries].nil? or 
        params[:total_entries].empty? or params[:total_entries].to_i <= 1
        total_entries = Ndcg.get_queries(winning, nil, query_segment, cat_id,
                                        @date, 0).length
      else
        total_entries = params[:total_entries].to_i
      end
    else
      total_entries = 1
    end

    respond_to do |format|
      format.json { render :json => [
        {total_entries: total_entries},
        Ndcg.get_queries(winning, query, query_segment, cat_id,
                         @date, @page, @limit, @sort_by, @order)]}
    end	
  end

  def get_winners
    get_queries(true)
  end
  
  def get_loosers
    get_queries(false)
  end

  def get_daily_change
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0
    metric_id = params[:metric_id]

    if metric_id =~ /conv_rel_corr/i
      get_metrics(SearchQualityDaily, query_segment, cat_id, metric_id)
    
    elsif metric_id =~ /ndcg/i
      get_metrics(Ndcg, query_segment, cat_id, metric_id)
    
    elsif metric_id =~ /traffic/i
      get_metrics(Traffic, query_segment, cat_id, metric_id)
    
    elsif metric_id =~ /pvr/i
      get_metrics(Pvr, query_segment, cat_id, metric_id)
    
    elsif metric_id =~ /atc/i
      get_metrics(Atc, query_segment, cat_id, metric_id)
    
    elsif metric_id =~ /conversion/i
      get_metrics(Conversion, query_segment, cat_id, metric_id)
    end
  end

  def get_metrics(klass, query_segment, cat_id, metric_id)
    results = klass.send(
      :get_daily_metrics, query_segment, cat_id, @date)
    change = results.first.score.to_f/results.last.score*100 - 100
    score = results.first.score
    queries = []
    klass.send(:get_queries, true, query_segment,
               cat_id, @date, 1, 5).each do |record|
      queries.push(record.query)
    end
        
    respond_to do |format|
      format.json do render :json => {
        metric_id: metric_id,
        score: results.first.score.to_f.round(3),
        change: change.to_f.round(2),
        queries: queries}
      end
    end
  end
end
