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

  model: Searchad.Models.PoorPerforming
  url: '/poor_performing/get_search_words.json'
  
  filters:
    date: null
    cat_id: null
  
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
