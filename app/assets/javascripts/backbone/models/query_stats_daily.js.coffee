class Searchad.Models.QueryStatsDaily extends Backbone.Model

class Searchad.Collections.QueryStatsDailyCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @query = null
    super(options)
  
  model: Searchad.Models.QueryStatsDaily
  url: =>
    @controller.svc_base_url + '/query_stats/get_daily_info'

  mode: 'client'
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
