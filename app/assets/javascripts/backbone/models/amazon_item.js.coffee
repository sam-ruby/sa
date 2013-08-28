class Searchad.Models.PoorPerfAmazonItem extends Backbone.Model
  paramRoot: 'poor_performing_amazon_items'

  defaults:
    item_id: null
    idd: null
    name: null
    brand: null
    position: null
    'amazon.name': null
    brand: null
    img_url: null
    'amazon.url': null
    newprice: null

class Searchad.Collections.PoorPerfAmazonItemsCollection extends Backbone.PageableCollection
  
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
  
  model: Searchad.Models.PoorPerfAmazonItem
  url: '/poor_performing/get_amazon_items.json'
  filters:
    date: null
  state:
    pageSize: 5
  query_params:
    currentPage: 'page'
    pageSize: 'per_page'
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
