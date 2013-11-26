class Searchad.Models.CAAmazonItem extends Backbone.Model
  defaults:
    all_items: null
    in_top_32: null
    not_in_top_32: null

class Searchad.Collections.CAAmazonItemsCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.CAAmazonItem
  url: '/poor_performing/get_amazon_items.json'
  state:
    pageSize: 8
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
