class Searchad.Models.QueryMonitoringMetrics extends Backbone.Model
  # paramRoot: 'query'
  defaults:
    query: null
    query_score: null
    count: null
    con: null
    con_trend_score:null
    con_ooc_score:null
    pvr: null
    pvr_trend_score: null
    pvr_ooc_score:null
    atc: null
    atc_trend_score:null
    atc_ooc_score:null

class Searchad.Collections.QueryMonitoringCountCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @query = null
    super(options)

  model: Searchad.Models.QueryMonitoringCount
  url: '/monitoring/metric/get_metric_monitor_table_data.json'
  # filters:
  #   date: null

  state:
    pageSize: 10
  mode: 'server'
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date


  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data)