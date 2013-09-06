class Searchad.Models.QueryItem extends Backbone.Model
  paramRoot: 'query'

  defaults:
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

class Searchad.Collections.QueryItemsCollection extends Backbone.PageableCollection
  initialize: ->
    @controller = SearchQualityApp.Controller

  model: Searchad.Models.QueryItem
  url: '/search_rel/get_query_items.json'
  filters:
    date: null
  data:
    id: null
    query_items: null
    top_rev_items: null

  state:
    pageSize: 5
  mode: 'client'

  get_items: (data) =>
    if data
      for k, v of data
        @data[k] = v
    else
      data = @data
    @filters.date = data.date if data.date
    for k, v of @filters
      continue unless v
      data[k] = v
    @fetch(
      reset: true
      data: @data
      type: 'post'
    )

  parse: (response) =>
    if response and response.query
      @controller.trigger('search-rel:query-items:set-tab-content', response.query)
    if response and response.results
      response.results
