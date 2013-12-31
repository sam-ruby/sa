# QueryMetricsMonitoring Model 
# @author Linghua Jin
# @since Dec, 2013
# This is the model for generating query metics monitoring daily
# query_search_metrics_monitoring_daily maintained by Zhenrui Wang

class QueryMetricsMonitoring < BaseModel
  
  self.table_name = 'query_search_metrics_monitoring_daily'
  # this function generate the query metric monitoring table
  def self.get_query_metrics_monitoring_daily(query, data_date, page, order_column, order, limit)
    # set rank order, order will be changed when click on certain column of the grid
    # The re-ordering event will be triggered from backgrid
    if order_column.blank?
      order_str = "con_rank_score desc"
    else
      order_str = order_column
      order_str << ' ' << order
    end 
    # define select field
    # TODO: discuss the select with Hang, should we do con_trend_score * con_ooc_flag as con_trend_score,
  	selects = %q{query, count, 
      con, con_ooc_score, con_trend_score, 
      sqrt(count)*(con_ooc_score+con_trend_score) as con_rank_score, 
      pvr, pvr_ooc_score, pvr_trend_score,
      sqrt(count)*(pvr_ooc_score+pvr_trend_score) as pvr_rank_score, 
      atc, atc_ooc_score, atc_trend_score,
      sqrt(count)*(atc_ooc_score+atc_trend_score) as atc_rank_score
    }
    # do query
    if query && query!="" 
    	QueryMetricsMonitoring.select(selects).where(%q{query = ? and data_date = ? }, query, data_date)
      .order(order_str)
    	.page(page).limit(limit)
    else
      p "do all query"
      QueryMetricsMonitoring.select(selects).where(%q{data_date = ? }, data_date)
      .order(order_str)
      .page(page).limit(limit)
    end
  end

  # get_query_stats generate the data for the query monitoring graph
  def self.get_query_stats(query, stats_type)
    # by default, set the stats to be conversion rate, since it is the most important
    if stats_type.blank? 
      stats_type = "con"
    end
    # generate different select if incoming request is for conversion rate, or atc or pvr. 
    # the top three option could be eliminate if the final decision is to draw three charts all togheter
    # since we might switch between chart, we keep three type for now.
    if stats_type == "con"
      selects = %q{unix_timestamp(data_date) * 1000 as data_date, 
        con_UCL, con_LCL, con_metric, con_trend, con_OOC_flag}
    elsif stats_type == "atc"
      selects = %q{unix_timestamp(data_date) * 1000 as data_date, 
        atc_UCL, atc_LCL, atc_metric, atc_trend, atc_OOC_flag}
    elsif stats_type == "pvr"
      selects = %q{unix_timestamp(data_date) * 1000 as data_date, 
        pvr_UCL, pvr_LCL, pvr_metric, pvr_trend, pvr_OOC_flag}
    elsif stats_type == "all"
      selects = %q{unix_timestamp(data_date) * 1000 as data_date, 
        pvr_UCL, pvr_LCL, pvr_metric, pvr_trend, pvr_OOC_flag, 
        con_UCL, con_LCL, con_metric, con_trend, con_OOC_flag,
        atc_UCL, atc_LCL, atc_metric, atc_trend, atc_OOC_flag
     }
    end
    # do the query
    QueryMetricsMonitoring.select(selects).where(
    [%q{query = ?}, query]).order("data_date")
  end
end