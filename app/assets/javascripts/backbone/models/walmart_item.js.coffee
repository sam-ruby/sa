class Searchad.Models.PoorPerfWalmartItem extends Backbone.Model
  paramRoot: 'poor_performing_walmart_items'

  defaults:
    item_id: null
    item_revenue: null
    shown_count: null
    item_con: null
    item_atc: null
    item_pvr: null
    revenue: null
    title: null
    image_url: null

class Searchad.Collections.PoorPerfWalmartItemsCollection extends Backbone.PageableCollection
  model: Searchad.Models.PoorPerfWalmartItem
  url: '/poor_performing/get_walmart_items.json'
  filters:
    date: null
  state:
    pageSize: 10
  mode: 'client'
  data:
    query: null
  
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
    )
