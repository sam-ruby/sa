class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  routes:
    "search_rel(/query/:query)(/filters/*wday)": "search_rel"
    "search_rel/item_id/:id(/filters/*wday)": "search_query_items"
    
    "search_kpi(/filters/*wday)": "search_kpi"
    "(filters/*wday)": "search_kpi"
    
    "poor_performing(/query/:query)(/filters/*wday)": "poor_performing"
    ###
    "comp_analysis(/filters/*wday)": "comp_analysis"
    "comp_analysis/query/:query(/filters/*wday)": "comp_analysis_stats"
    ###
    
    "search(/query/:query)(/filters/*wday)": "adhoc_search"
    
    "query_perf_comparison(/query/:query/wks_apart/:weeks/query_date/:date)(/filters/*wday)":
      "query_perf_comparison"

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

  query_perf_comparison: (query, weeks, search_date) =>
    @controller.trigger('query-perf-comp:app')
    @controller.trigger('query-comparison',
      query: query
      weeks_apart: weeks
      query_date: search_date)
  
  search_rel: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger(
      'search-rel:index', query: decodeURIComponent(query)) if query

  search_kpi: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('relevance:app')
    @controller.trigger('search-kpi:index')

  adhoc_search: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('query-perf-comp:app')
    @controller.trigger('adhoc-search:index')
    @controller.trigger('search:form')
    @controller.trigger(
      'load-search-results', decodeURIComponent(query)) if query
  
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
  
  poor_performing: (search_rel, date_parts) =>
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

  comp_analysis_stats: (query, date_parts) =>
    console.log('here is the query' + query)
    @set_date_info(date_parts)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index',
      saveQuery: true
      query: decodeURIComponent(query))
  
  ca_amazon_items: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index',
      query: decodeURIComponent(query)
      saveQuery: true)
    
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

