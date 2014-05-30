class Searchad.Models.QueryStatsDaily extends Backbone.Model
  defaults:
    query_count: null
    query_pvr: null
    query_atc: null
    query_con: null
    query_revenue: null

class Searchad.Collections.QueryStatsDailyCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @query = null
    super(options)
  
  model: Searchad.Models.QueryStatsDaily
  url: '/search/get_query_stats_date.json'
  mode: 'server'
  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    query: ->
      @query

  mode: 'server'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      data: data
      reset: true)
