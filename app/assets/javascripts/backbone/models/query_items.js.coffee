class Searchad.Models.QueryItem extends Backbone.Model
  paramRoot: 'query'

  defaults:
    position: null
    walmart_item:
      item_id: null
      title: null
      image_url: null
      curr_item_price: null
    rev_based_item:
      item_id: null
      title: null
      image_url: null
      curr_item_price: null
    revenue: null

class Searchad.Collections.QueryItemsCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.QueryItem
  url: '/search_rel/get_query_items.json'
  filters:
    date: null

  state:
    pageSize: 5
  mode: 'client'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data)

