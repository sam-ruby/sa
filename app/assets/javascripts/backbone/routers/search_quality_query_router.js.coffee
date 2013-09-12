class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = options.controller

  routes:
    "search_rel(/filters/*wday)": "search_rel"
    "search_rel/item_id/:id(/filters/*wday)": "search_query_items"
    "(filters/*wday)": "search_rel"

    "search_kpi(/filters/*wday)": "search_kpi"
    
    "poor_performing(/filters/*wday)": "poor_performing"
    "poor_performing/stats/query/:query(/filters/*wday)":
      "pp_stats"
    "poor_performing/walmart_items/query/:query(/filters/*wday)":
      "pp_walmart_items"
    "poor_performing/amazon_items/query/:query(/filters/*wday)":
      "pp_amazon_items"

    "comp_analysis(/filters/*wday)": "comp_analysis"
    "comp_analysis/walmart_items/query/:query(/filters/*wday)":
      "ca_walmart_items"
    "comp_analysis/amazon_items/query/:query(/filters/*wday)":
      "ca_amazon_items"

    "search(/filters/*wday)": "search"
    "search/query/:query(/filters/*wday)": "search"
    "search/amazon_items/query/:query(/filters/*wday)":
      "search_amazon_items"
    
  set_date_info: (date_part) =>
    return unless date_part
    date_parts = date_part.split('/')
    for part, i in date_part.split('/')
      if part == 'date'
        @controller.set_date(date_parts[i+1])
      else if part == 'year'
        @controller.set_year(date_parts[i+1])
      else if part == 'week'
        @controller.set_week(date_parts[i+1])

  search_rel: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('search-kpi:index')

  search_query_items: (id, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('search-rel:index', id: id)
  
  search_kpi: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('search-kpi:index')

  search: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('do-search', query: decodeURIComponent(query))
  
  search_amazon_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('do-search', query: query)
    @controller.trigger('search:amazon-items:index',
      query: decodeURIComponent(query))
  
  dashboard: (date_parts) =>
    @set_date_info(date_parts)
    @controller.set_date(date)
    @controller.trigger('dashboard:index')
  
  poor_performing: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('poor-performing:index', trigger: true)

  pp_stats: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('poor-performing:index',
      query: decodeURIComponent(query))

  pp_walmart_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('poor-performing:index', trigger: false)
    @controller.trigger('pp:walmart-items:index',
      query: decodeURIComponent(query))
  
  pp_amazon_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('poor-performing:index', trigger: false)
    @controller.trigger('pp:amazon-items:index',
      query: decodeURIComponent(query))
  
  comp_analysis: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index')

  ca_walmart_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index')
    @controller.trigger('ca:walmart-items:index',
      query: decodeURIComponent(query))
  
  ca_amazon_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index',
      query: decodeURIComponent(query))
    
  
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
    @navigate(new_path, trigger: false)

