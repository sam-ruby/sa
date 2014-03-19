class PoorPerformingController < BaseController
  before_filter :set_common_data
  
  def get_search_words
    query = params[:query]
    total_records = (query.nil? or query.empty?) ? 2000 : 1
    respond_to do |format|
      format.json do 
        @search_words = QueryCatMetricsDaily.get_search_words(
          query, @date, @page, @sort_by, @order, @limit)
        if @search_words.nil? or @search_words.empty?
          render :json => [{:total_entries => 0}, @search_words]
        else
          render :json => [
              {:total_entries => total_records}, @search_words]
        end
      end
      format.csv do
        results = QueryCatMetricsDaily.get_search_words(
          query, @date, 0).map do |record|
            {'Query' => record.query,
             'Rank' => record.rank,
             'Total Search Revenue' => record.revenue.to_f.round(2),
             'Total Count' => record.query_count,
             'Conversion' => record.query_con.to_f.round(2),
             'ATC' => record.query_atc.to_f.round(2),
             'PVR' => record.query_pvr.to_f.round(2)}
          end
        render :json => results
      end
    end
  end
  
  def get_trending_words
    query = params[:query]
    period = params[:period] || '2d'
    if period == '2d'
      period_days = 2
    elsif period == '1w'
      period_days = 7
    elsif period == '2w'
      period_days = 14
    elsif period == '3w'
      period_days = 21
    elsif period == '4w'
      period_days = 28
    end

    if query.nil? or query.empty?
      if params[:total_entries].nil? or 
        params[:total_entries].empty? or params[:total_entries].to_i <= 1
        total_entries =
          TrendingQueriesDaily.get_trending_words_count(@date, period_days)
      else
        total_entries = params[:total_entries].to_i
      end
    else
      total_entries = 1
    end

    respond_to do |format|
      format.json do 
        search_words = TrendingQueriesDaily.get_trending_words(
          query, @date, period_days, @page, @sort_by, @order, @limit)
        if search_words.nil? or search_words.empty?
          render :json => [{:total_entries => 0}, search_words]
        else
          render :json => [
              {:total_entries => total_entries}, search_words]
        end
      end
      format.csv do
        results = TrendingQueriesDaily.get_trending_words(
          query, @date, period_days, 0).map do |record|
            {'Query' => record.query,
             'Total Count' => record.query_count,
             'Total Search Revenue' => record.revenue.to_f.round(2),
             'Conversion' => record.query_con.to_f.round(2),
             'ATC' => record.query_atc.to_f.round(2),
             'PVR' => record.query_pvr.to_f.round(2)}
          end
        render :json => results
      end
    end
  end

  
  def get_query_stats
    query = params['query']
    respond_to do |format|
      format.json do 
        render :json => QueryCatMetricsDaily.get_query_stats(query)
      end
    end
  end

end
