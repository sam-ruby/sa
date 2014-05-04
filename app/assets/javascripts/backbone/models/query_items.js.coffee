class Searchad.Models.QueryItem extends Backbone.Model

class Searchad.Collections.QueryItemsCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.QueryItem
  url: '/search_rel/get_query_items.json'
  filters:
    date: null

  state:
    pageSize: 8
  mode: 'client'

  get_items: (data) =>
    data = {} unless data
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: data)
  
  comparator: (a) ->
    score = parseInt(a.get('in_top_16')) * 100 + parseInt(a.get('position'))
    score
