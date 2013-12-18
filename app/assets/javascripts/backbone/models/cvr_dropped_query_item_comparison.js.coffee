class Searchad.Models.CvrDroppedQueryComparisonItem extends Backbone.Model

  defaults:
    item_id_before: null
    item_title_before: null  
    item_url_before:null
    seller_name_before:null
    item_id_after: null
    item_title_after:null
    item_url_after:null
    seller_name_after:null



class Searchad.Collections.CvrDroppedQueryComparisonItemCollection extends Backbone.PageableCollection
  
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)
  
  model: Searchad.Models.CvrDroppedQueryComparisonItem
  url: '/search/get_cvr_dropped_query_item_comparison.json'
  state:
    pageSize: 8
  mode: 'client'
  data:
    query: null
    query_date:null
  
  get_items: (data) =>
    # data = {} unless data
    # if data.query
    #   @data.query = data.query
    # else
    #   data.query = @data.query
    # for k, v of @controller.get_filter_params()
    #   continue unless v
    #   data[k] = v
    @fetch(
      reset: true
      data: data
    )