class Searchad.Models.CvrDroppedQueryComparisonItem extends Backbone.Model

  defaults:
    cvr_dropped_item_comparison_rank: null
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
    pageSize: 16
  mode: 'client'
  data:
    query: null
    query_date:null

  parse: (response) =>
    @data_date_before = response.data_date_before
    @data_date_after = response.data_date_after
    response.items
  
  get_items: (data) =>
    @fetch(
      reset: true
      data: data
    )
