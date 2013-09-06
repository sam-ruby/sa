class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = options.controller
    
  routes:
    "search_rel(/filters/date/:date)": "search_rel"
    "search_rel/item_id/:id(/filters/date/:date)": "search_query_items"
    "(filters/date/:date)": "search_rel"

    "search_kpi(/filters/date/:date)": "search_kpi"
    
    "poor_performing(/filters/date/:date)": "poor_performing"
    "poor_performing/stats/query/:query(/filters/date/:date)":
      "pp_stats"
    "poor_performing/walmart_items/query/:query(/filters/date/:date)":
      "pp_walmart_items"
    "poor_performing/amazon_items/query/:query(/filters/date/:date)":
      "pp_amazon_items"

    "comp_analysis(/filters/date/:date)": "comp_analysis"
    "comp_analysis/walmart_items/query/:query(/filters/date/:date)":
      "ca_walmart_items"
    "comp_analysis/amazon_items/query/:query(/filters/date/:date)":
      "ca_amazon_items"

    "search(/filters/date/:date)": "search"
    "search/query/:query(/filters/date/:date)": "search"
    "search/amazon_items/query/:query(/filters/date/:date)":
      "search_amazon_items"
    
  search_rel: (date) =>
    @controller.set_date(date)
    @controller.trigger('relevance:app')
    @controller.trigger('search-rel:index')

  search_query_items: (id, date) =>
    @controller.set_date(date)
    @controller.trigger('relevance:app')
    @controller.trigger('search-rel:index', id: id)
  
  search_kpi: (date) =>
    @controller.set_date(date)
    @controller.trigger('relevance:app')
    @controller.trigger('search-kpi:index')

  search: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('relevance:app')
    @controller.trigger('do-search', query: query)
  
  search_amazon_items: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('relevance:app')
    @controller.trigger('do-search', query: query)
    @controller.trigger('search:amazon-items:index', query: query)
  
  dashboard: (date) =>
    @controller.set_date(date)
    @controller.trigger('dashboard:index')
  
  poor_performing: (date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('poor-performing-stats:index')

  pp_stats: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('poor-performing:index')
    @controller.trigger('pp:stats:index', query: query)

  pp_walmart_items: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('poor-performing:index')
    @controller.trigger('pp:walmart-items:index',
      query: query)
  
  pp_amazon_items: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('poor-performing:index')
    @controller.trigger('pp:amazon-items:index', query: query)
  
  comp_analysis: (date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index')

  ca_walmart_items: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index',
      query: query)
  
  ca_amazon_items: (query, date) =>
    @controller.set_date(date)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index')
    @controller.trigger('ca:amazon-items:index', query: query)
  
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

