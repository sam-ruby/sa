class Searchad.Models.QueryItem extends Backbone.Model

class Searchad.Collections.QueryItemsCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.QueryItem
  url: =>
    @controller.svc_base_url + '/rel_items/get_top_recom_items'
  mode: 'client'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data)
