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
  state:
    pageSize: 8
  mode: 'client'
  # since it is client side pagination, query param don't matter
  get_items: (data) =>
    @data = data
    @fetch(
      reset: true
      data: @data
    )
