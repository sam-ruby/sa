#= require backbone/models/conv_cor

class Searchad.Models.QueryReformulation extends Backbone.Model

class Searchad.Collections.QueryReformulation extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.QueryReformulation
  url: =>
    @controller.svc_base_url + '/opportunities/query_reformulations'
  
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    cat_id: ->
      @controller.get_filter_params().cat_id
    query: ->
      @query

