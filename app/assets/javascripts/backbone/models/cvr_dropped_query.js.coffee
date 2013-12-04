class Searchad.Models.CvrDroppedQuery extends Backbone.Model
  defaults:
    query: null
    con_before: null
    con_after:null
    weeks_apart:null


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
    sum_count: ->
      @dataParam.sum_count
    query_date:->
      @dataParam.query_date
    weeks_apart:->
      @dataParam.weeks_apart
  mode: 'server'

  get_items: (data) =>
    @fetch(
      data: @dataParam
      reset: true)
