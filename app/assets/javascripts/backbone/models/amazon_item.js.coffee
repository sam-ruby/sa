class Searchad.Models.PoorPerfAmazonItem extends Backbone.Model
  defaults:
    position: null
    name: null
    brand: null
    newprice: null
    curr_item_price: null

class Searchad.Collections.PoorPerfAmazonItemsCollection extends Backbone.PageableCollection
  
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)
  
  model: Searchad.Models.PoorPerfAmazonItem
  url: '/poor_performing/get_amazon_items.json'
  state:
    pageSize: 6
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
