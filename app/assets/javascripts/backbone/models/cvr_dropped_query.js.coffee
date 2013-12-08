class Searchad.Models.CvrDroppedQuery extends Backbone.Model
  defaults:
    query: null
    query_con_before: null
    query_con_after:null
    query_count_before:null
    query_count_after:null
    query_revenue_before:null
    query_revenue_after:null
    query_con_diff:null
    query_score:null


class Searchad.Collections.CvrDroppedQueryCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @dataParam={}
    super(options)
  
  model: Searchad.Models.CvrDroppedQuery
  url: '/search/get_cvr_dropped_query.json'
  mode: 'server'
  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    query_date:->
      @dataParam.query_date
    weeks_apart:->
      @dataParam.weeks_apart
  mode: 'server'

  get_items: (data) =>
    @fetch(
      data: @dataParam
      reset: true)
