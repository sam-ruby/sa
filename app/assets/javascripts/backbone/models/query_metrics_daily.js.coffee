class Searchad.Models.QueryCatMetricsDaily extends Backbone.Model
  paramRoot: 'query'

  defaults:
    before_week:
      data:
        query_count: null
        query_pvr: null
        query_atc: null
        query_con: null
        query_revenue: null
      title: null
    after_week:
      data:
        query_count: null
        query_pvr: null
        query_atc: null
        query_con: null
        query_revenue: null
      title: null

class Searchad.Collections.QueryCatMetricsDailyCollection extends Backbone.PageableCollection
  initialize: ->
    @controller = SearchQualityApp.Controller
  
  model: Searchad.Models.QueryCatMetricsDaily
  url: '/search/get_data.json'
  mode: 'client'

  get_items: (data) =>
    @fetch(
      reset: true
      data: data
    )
