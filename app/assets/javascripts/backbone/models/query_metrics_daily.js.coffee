# class Searchad.Models.QueryCatMetricsDaily extends Backbone.Model
#   paramRoot: 'query'

#   defaults:
#     before_week:
#       data:
#         query_count: null
#         query_pvr: null
#         query_atc: null
#         query_con: null
#         query_revenue: null
#       title: null
#     after_week:
#       data:
#         query_count: null
#         query_pvr: null
#         query_atc: null
#         query_con: null
#         query_revenue: null
#       title: null

# class Searchad.Collections.QueryCatMetricsDailyCollection extends Backbone.PageableCollection
#   initialize: (options) ->
#     @controller = SearchQualityApp.Controller
#     super()
  
#   model: Searchad.Models.QueryCatMetricsDaily
#   url: '/search/get_data.json'
#   mode: 'client'

#   get_items: (data) =>
#     data = {} unless data
#     for k, v of @controller.get_filter_params()
#       continue unless v
#       data[k] = v
#     @fetch(
#       reset: true
#       data: data
#     )
