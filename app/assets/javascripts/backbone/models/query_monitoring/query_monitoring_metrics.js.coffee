class Searchad.Models.QueryMonitoringMetric extends Backbone.Model
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

class Searchad.Collections.QueryMonitoringMetricCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @data = {
      query: null
      date: null
    }
    super(options)
  model: Searchad.Models.QueryMonitoringMetric
  url: '/monitoring/metric/get_metric_monitor_table_data.json'
  state:
    currentPage:null
    pageSize: 10
  mode: 'server'
  # Backbone.PageableCollection#queryParams` converts to ruby's will_paginate keys by default.
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date:->
      @data.date
    query:->
      @data.query