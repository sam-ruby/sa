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
    @controller.bind('collections:update-date', (data) =>
      @filters.date = data.date if data and data.date
    )

  model: Searchad.Models.SearchQualityQuery
  url: '/search_quality_query/get_search_words.json'
  filters:
    date: null
  state:
    pageSize: 10
  query_params:
    currentPage: 'page'
    pageSize: 'per_page'
  mode: 'server'

  get_items: (data) =>
    @filters.date = data.date if data and data.date
    data = {} unless data
    for k, v of @filters
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data
    )
