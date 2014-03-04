class Searchad.Models.UpTrending extends Backbone.Model
  defaults:
    query: null
    query_count: null
    query_revenue: null
    query_pvr: null
    query_con: null

class Searchad.Collections.UpTrendingCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  model: Searchad.Models.UpTrending
  url: '/poor_performing/get_trending_words.json'
  
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
