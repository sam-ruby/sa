class Searchad.Models.PoorPerforming extends Backbone.Model
  paramRoot: 'search_quality_daily'

  defaults:
    id: null
    cat_id: null
    query: null
    query_date: null
    channel: null
    query_count: null
    query_revenue: null
    query_pvr: null
    query_atc: null
    query_con: null

class Searchad.Collections.PoorPerformingCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('collections:update-date', (data) =>
      @filters.date = data.date if data and data.date
    )

  model: Searchad.Models.PoorPerforming
  url: '/poor_performing/get_search_words.json'
  filters:
    date: null
    cat_id: null
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
