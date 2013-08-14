class Searchad.Routers.QueryItemsRouter extends Backbone.Router
  initialize: (options) ->
    @controller = options.controller

  routes:
    "query_items/get_items/item_id/:id(/filters/date/:date)": "get_items"

  get_items: (id, date) =>
    @controller.trigger('search_quality_dailies:index', date: date)
    @controller.trigger('query_items:index', {id: id})
