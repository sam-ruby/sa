class Searchad.Models.QueryMonitoringCount extends Backbone.Model
  paramRoot: 'query'

  defaults:
    query_str: null
    query_score: null
    query_count: null
    query_con: null
    days_alarmed: null
    days_abovemean: null
    z_score: null

class Searchad.Collections.QueryMonitoringCountCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @query = null
    super(options)

  model: Searchad.Models.QueryMonitoringCount
  url: '/monitoring/count/get_words.json'
  filters:
    date: null

  state:
    pageSize: 10
  mode: 'server'
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    query: ->
      @query


  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data)

