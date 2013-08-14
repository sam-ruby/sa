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
  model: Searchad.Models.QueryItem
  url: '/query_items/get_items.json'
  filters:
    id: null
    query_items: null
    top_rev_items: null
    date: null
  state:
    pageSize: 16
  mode: 'client'

  get_items: (data) =>
    @filters.id = data.id if data.id
    @filters.query_items = data.query_items if data.query_items
    @filters.top_rev_items = data.top_rev_items if data.top_rev_items
    @filters.date = data.date if data.date
    data = {}

    for k, v of @filters
      continue unless v
      data[k] = v

    @fetch(
      reset: true
      data: data
      type: 'post'
    )
