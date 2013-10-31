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
    super(options)
  
  model: Searchad.Models.QueryStatsDaily
  url: '/search/get_query_stats_date.json'
  mode: 'client'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v

    @fetch(
      reset: true
      data: data
    )
