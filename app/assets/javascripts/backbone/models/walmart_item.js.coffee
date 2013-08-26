class Searchad.Models.PoorPerfWalmartItem extends Backbone.Model
  paramRoot: 'poor_performing_walmart_items'

  defaults:
    item_id: null
    item_revenue: null
    shown_count: null
    item_con: null
    item_atc: null
    item_pvr: null
    revenue: null
    title: null
    image_url: null

class Searchad.Collections.PoorPerfWalmartItemsCollection extends Backbone.PageableCollection
  
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
  
  model: Searchad.Models.PoorPerfWalmartItem
  url: '/poor_performing/get_walmart_items.json'
  state:
    pageSize: 5
  mode: 'client'
  data:
    query: null
  
  get_items: (data) =>
    data = {} unless data
    if data.query
      @data.query = data.query
    else
      data.query = @data.query
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data
    )
