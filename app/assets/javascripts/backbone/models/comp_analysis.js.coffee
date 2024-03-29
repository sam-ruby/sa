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
  mode: 'server'

  fetch: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    super({reset: true, data: data})
