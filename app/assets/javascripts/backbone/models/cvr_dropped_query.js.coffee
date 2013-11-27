class Searchad.Models.CvrDroppedQuery extends Backbone.Model
  defaults:
    query: null
    con_before: null
    con_after:null
    weeks_apart:null


class Searchad.Collections.CvrDroppedQueryCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @query = null
    super(options)
  
  model: Searchad.Models.CvrDroppedQuery
  # url: '/search/get_query_stats_date.json'
  url: '/search/get_cvr_dropped_query.json'
  mode: 'server'
  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    query: ->
      @query

  mode: 'server'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    console.log(data);
    @fetch(
      data: data
      reset: true)
