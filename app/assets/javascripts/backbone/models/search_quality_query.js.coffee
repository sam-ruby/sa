class Searchad.Models.SearchQualityQuery extends Backbone.Model
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
    rank_metric:null

class Searchad.Collections.SearchQualityQueryCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    # @query = null
    super(options)
    @data={
      query: null
      date: null
    }

  get_date: ->
    @date

  model: Searchad.Models.SearchQualityQuery
  url: '/search_rel/get_search_words.json'
  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    query: ->
      @data.query

  mode: 'server'

  get_items: (data) =>
    @fetch(
      reset: true
      data: data
    )
