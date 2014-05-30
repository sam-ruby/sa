class SearchRelController < BaseController

  before_filter :set_common_data

  def get_search_words
    query = params[:query] 
    year_week = get_week_from_date(@date)
    week = year_week[:week]
    year = year_week[:year]

    respond_to do |format|
      format.json do 
        @search_words = SearchQualityDaily.get_query_stats(
          query, year, week, @date, @page, @limit, @sort_by, @order)
        if @search_words.nil? or @search_words.empty?
          render :json => [{:total_entries => 0}, @search_words]
        else
          render :json => [
            {:total_entries => 500, :date => @date}, @search_words]
        end
      end
      format.csv do |format|
        result = SearchQualityDaily.get_query_stats(
          query, year, week, @date, 1,10000).map do|record|
            {'Query String' => record.query,
             'Query Count' => record.query_count,
             'Rank Metric' => record.rank_metric.to_f.round(2),
             'Catalog Overlap' => record.cat_rate.to_f.round(2),
             'Results Shown in Search' => record.show_rate.to_f.round(2),
             'Overall Relevance Score' => record.rel_score.to_f.round(2), 
             'Conversion Rank Correlation' =>
                record.search_con_rank_correlation.to_f.round(2),
             'Query Revenue' => record.revenue,
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
    date = @date

    query_dates = (date-28.days..date-1.days).to_a
    results = SearchQualityDailyV2.get_search_relevance_data_by_word(
      query_str, date)
    return results if results.empty?
  
    missed_items = JSON.parse(
      results.first['ideal_items_not_in_top16_json']) rescue nil
    query_items = JSON.parse(results.first['rel_item_rank_json']) rescue nil
    return results if query_items.nil? or missed_items.nil?
    
    item_details = {}
    top_5_missed_index = 0
    missed_items.each do |ideal_rank, details|
      break if top_5_missed_index > 4
      details[:position] = ideal_rank
      details[:in_top_16] = 0 
      item_details[details['item_id']] = details
      top_5_missed_index += 1
    end
    query_items.each do |position, details|
      details[:position] = position
      details[:in_top_16] = 1
      item_details[details['item_id']] = details
    end

    AllItemAttrs.get_item_details(
      query_str, item_details.keys, query_dates).each do |item|
        item_details[item.item_id.to_i][:title] = item.title 
        item_details[item.item_id.to_i][:image_url] = item.image_url
        item_details[item.item_id.to_i][:curr_item_price] = item.curr_item_price
        item_details[item.item_id.to_i][:oos] = item.i_oos
      end
    item_details.keys.map {|key| item_details[key]}
  end

  def get_comp_analysis
    query = params[:query]
    if params[:fuzzy]
      fuzzy = !params[:fuzzy].match(/true/i).nil?
    else
      fuzzy = false
    end
    year_week = get_week_from_date(@date)
    week = year_week[:week]
    year = year_week[:year]

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
