class Searchad.Models.CAWalmartItem extends Backbone.Model

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
  url: =>
    @controller.svc_base_url + '/rel_items/get_top_items'
  mode: 'client'
  
  # since it is client side pagination, query param don't matter
  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    for k, v of data
      @data[k] = v
    @fetch(
      reset: true
      data: @data
    )
