class Searchad.Models.CompAnalysis extends Backbone.Model
  defaults:
    query: null
    catalog_overlap: null
    results_shown_in_search: null
    overall_relevance_score: null

class Searchad.Collections.CompAnalysisCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  model: Searchad.Models.CompAnalysis
  url: '/search_rel/get_comp_analysis.json'
  state:
    pageSize: 10
  
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    week: ->
      @controller.get_filter_params().week
    year: ->
      @controller.get_filter_params().year
  
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
