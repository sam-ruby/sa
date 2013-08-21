class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = options.controller
    
  routes:
    "search(/filters/date/(:date))": "search"
    "search/item_id/:id(/filters/date/:date)": "search_query_items"

    "search.*": "search"
    "poor_performing(/filters/date/:date)": "poor_performing"

    "poor_performing/walmart_items/query/:query(/filters/date/:date)":
      "pp_walmart_items"
    
    "poor_performing/amazon_items/query/:query(/filters/date/:date)":
      "pp_amazon_items"

    ".*(filters/date/:date)"        : "dashboard"

  search: (date) =>
    @controller.trigger('search-quality-query:index', date: date)

  search_query_items: (id, date) =>
    @controller.trigger('search-quality-query:index', date: date)
    @controller.trigger('search:query-items:index',
      {id: id, date: date})
  
  dashboard: (date) =>
    @controller.trigger('dashboard:index', date: date)
  
  poor_performing: (date) =>
    @controller.trigger('poor-performing:index', date: date)

  pp_walmart_items: (query, date) =>
    @controller.trigger('poor-performing:index', date: date)
    @controller.trigger('pp:walmart-items:index',
      date: date
      query: query)
  
  pp_amazon_items: (query, date) =>
    @controller.trigger('poor-performing:index', date: date)
    @controller.trigger('pp:amazon-items:index',
      date: params
      query: query)
  
  update_path: (path) =>
    url_parts = window.location.hash.replace('#', '').split('filters')
    if url_parts.length > 0
      filters = url_parts[1]
    curr_path = url_parts[0]
    new_path = path
    if filters
      if new_path.indexOf('/') != (new_path.length - 1)
        new_path += '/'
      new_path += 'filters' + filters
    @navigate(new_path)

