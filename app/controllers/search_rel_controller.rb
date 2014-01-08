class SearchRelController < BaseController

  before_filter :set_common_data

  def get_search_words
    query = params[:query] 
    week = get_week_from_date(@date)["week"]
    year = get_week_from_date(@date)["year"]

    respond_to do |format|
      format.json do 
        @search_words = SearchQualityDaily.get_query_stats(
          query, year, week, @date, @page, @limit, @sort_by, @order)
        if @search_words.nil? or @search_words.empty?
          render :json => [{:total_entries => 0}, @search_words]
        else
          render :json => [
            {:total_entries => @search_words.total_pages * @limit,
             :date => @date}, @search_words]
        end
      end
      format.csv do |format|
        result = SearchQualityDaily.get_query_stats(
          query, @year, week, @date, 1,10000).map do|record|
            {'Query String' => record.query_str,
             'Query Count' => record.query_count,
             'Rank Metric' => record.rank_metric.to_f.round(2),
             'Catalog Overlap' => record.cat_rate.to_f.round(2),
             'Results Shown in Search' => record.show_rate.to_f.round(2),
             'Overall Relevance Score' => record.rel_score.to_f.round(2), 
             'Rev Rank Correlation' =>
                record.search_rev_rank_correlation.to_f.round(2),
             'Query Revenue' => record.query_revenue,
             'Query Conversion' => record.query_con.to_f.round(2)}
          end
          render :json => result
      end
    end
  end

  def get_query_items
    respond_to do |format|
      format.json do 
        render :json => get_items
      end
      format.csv do 
        render :json => get_items(:csv)
      end
    end
  end
  
  def get_items(mode=:json)
    query_str = params[:query]
    view = params[:view]
    result = []
    return result unless query_str
    date = @date
    query_dates = (date-14.days..date-1.days).to_a.map {|d|
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
      site_revenue = rev_item.total_revenue rescue 0

      if mode == :json
        result.push({:position => index,
                     :walmart_item => walmart_item,
                     :rev_based_item => rev_item,
                     :revenue => revenue,
                     :site_revenue => site_revenue,
                     :rev_rank => items[2].to_i + 1})
      else
        result.push({'Position' => index,
                     'Walmart Item Id' => walmart_item[:item_id],
                     'Walmart Item Title' => walmart_item[:title],
                     'Rev Rank' => items[2].to_i + 1,
                     'Walmart Item Image URL' => walmart_item[:image_url],
                     'Rev Based Item Id' => rev_item[:item_id],
                     'Rev Based Item Title' => rev_item[:title],
                     'Item Image URL' => rev_item[:image_url],
                     'Average Daily Item Revenue' =>
                        rev_item[:item_revenue].to_f.round(2),
                     'Average Daily Site Item Revenue' =>
                        rev_item[:total_revenue].to_f.round(2)})
      end
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
    week = get_week_from_date(@date)["week"]
    year = get_week_from_date(@date)["year"]

    @search_words = QueryPerformance.get_comp_analysis(
      query, week, year, fuzzy, @page, @sort_by, @order, @limit)
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
