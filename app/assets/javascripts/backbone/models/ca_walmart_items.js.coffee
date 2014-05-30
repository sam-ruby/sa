class Searchad.Models.CAWalmartItem extends Backbone.Model
  defaults:
    position: null
    name: null
    brand: null
    newprice: null
    curr_item_price: null

class Searchad.Collections.CAWalmartItemsCollection extends Backbone.PageableCollection
  
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)
    @data = {
      start_date:null
      end_date:null
      view:null
    }
  
  model: Searchad.Models.CAWalmartItem
  url: '/comp_analysis/get_walmart_items.json'
  mode: 'client'
  
  # since it is client side pagination, query param don't matter
  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v

    @data = data
    @fetch(
      reset: true
      data: @data
    )
