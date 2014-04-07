class SummaryMetricsController < BaseController
  before_filter :set_common_data
  
  def get_daily_change
    query_segment = params[:query_segment] || 'TOP QUERIES'  
    cat_id = params[:cat_id] || 0

    results = SummaryMetrics.get_metrics(query_segment, cat_id, @date)
    metrics = {}
    metrics_name = ''
    results.each_with_index do |record, index|
      next if metrics_name == record.metrics_name
      if results[index+1].nil? or results[index+1].metrics_name.nil? or
        results[index+1].value.nil?
        change = 100
      elsif record.metrics_name == results[index+1].metrics_name
        change = record.value.to_f/results[index+1].value*100 - 100
      else
        change = 100
      end

      if (!results[index+1].nil? and !results[index+1].lcl.nil? and
        !results[index+1].value.nil?)
        if (record.value > results[index+1].ucl) or 
          (record.value < results[index+1].lcl)
          confidence = true
        else
          confidence = false
        end
      end
      metrics[record.metrics_name] =  {
        id: record.metrics_name.gsub(/\s+/, '_'),
        name: record.metrics_name,
        change: change,
        confidence: confidence,
        queries: record.winners,
        score: record.value}
      metrics_name = record.metrics_name
    end
    respond_to do |format|
      format.json do render :json => metrics end
    end
  end
end
