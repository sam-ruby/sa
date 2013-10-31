class Searchad.Models.CompAnalysis extends Backbone.Model
  defaults:
    query: null
    catalog_overlap: null
    results_shown_in_search: null
    overall_relevance_score: null

class Searchad.Collections.CompAnalysisCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

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
  data:
    query: null
  mode: 'server'

  fetch: (data) =>
    data = {} unless data
    if data.query and data.saveQuery
      @data.query = data.query
      console.log 'saved the query'
    else if data.saveQuery == false
      @data.query = null
      data.query = null
    else
      data.query = @data.query
      console.log 'retrieving the query part ', data.query
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    super({reset: true, data: data})
