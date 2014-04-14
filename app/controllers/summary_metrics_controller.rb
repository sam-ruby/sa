class SummaryMetricsController < BaseController
  before_filter :set_common_data
  
  def get_daily_change
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0

    results = {}
    SummaryMetrics.get_metrics(query_segment, cat_id, @date).each do 
      |record|
      results[record.metrics_name] = [] if (
        results[record.metrics_name].nil?)
      results[record.metrics_name].push record
    end

    metrics = {}
    
    results.each do |key, values|
      change = 'N/A'
      significant = false
      if values.size == 2 
        if !values.last[:value].nil? and !values.first[:value].nil?
          change = values.first[:value].to_f/values.last[:value]*100 - 100
        end
      
        if !values.first[:value].nil? and !values.last[:lcl].nil? and
          !values.last[:ucl].nil?
          if values.first[:value] > values.last[:ucl] or 
              values.first[:value] < values.last[:lcl]
            significant = true
          end
        end
      end
      if values.first.data_date == @data_date
        score = values.first[:value]
        queries = values.first[:losers]
      else
        score = 'N/A'
        queries = 'N/A'
      end

      metrics[key] =  {
        id: key.gsub(/\s+/, '_'),
        name: values.first[:metrics_name],
        change: change,
        confidence: significant,
        queries: queries,
        score: score}
    end
    respond_to do |format|
      format.json do render :json => metrics end
    end
  end
end
