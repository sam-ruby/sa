class Searchad.Models.SearchQualityQuery extends Backbone.Model
  paramRoot: 'search_quality_query'

  defaults:
    id: null
    query_str: null
    query_date: null
    query_count: null
    query_revenue: null
    search_rev_rank_correlation: null
    ctr_ranks: null
    top_ctr_item: null
    query_items: null
    top_rev_items: null

class Searchad.Collections.SearchQualityQueryCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  get_date: ->
    @date

  model: Searchad.Models.SearchQualityQuery
  url: '/search_quality_query/get_search_words.json'
  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date

  mode: 'server'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data
    )
