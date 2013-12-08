class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  routes:
    "search_rel(/query/:query)(/filters/*wday)": "search_rel"
    "search_rel/item_id/:id(/filters/*wday)": "search_query_items"
    
    "search_kpi(/filters/*wday)": "search_kpi"
    "(filters/*wday)": "search_kpi"
    
    "poor_performing(/query/:query)(/filters/*wday)": "poor_performing"
    
    "search(/query/:query)(/filters/*wday)": "adhoc_search"
    
    "query_monitoring/count(/query/:query)(/filters/*wday)":
      "query_monitoring_count"
    "query_monitoring/metrics(/query/:query)(/filters/*wday)":
      "query_monitoring_metrics"
    "query_comparison(/query/:query/wks_apart/:weeks/query_date/:date)(/filters/*wday)":
      "query_comparison"
    "cvr_dropped_query(/wks_apart/:weeks/query_date/:date)(/filters/*wday)":
      "cvr_dropped_query"

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
   
  query_comparison: (query, weeks, search_date) =>
    if query?
      query = decodeURIComponent(query)
      @controller.trigger('query-comparison:index',
        query: query
        weeks_apart: weeks
        query_date: search_date)
    else
      @controller.trigger('query-comparison:index')


  cvr_dropped_query: (weeks, date) =>
    if weeks && date
      data=
        weeks_apart: weeks
        query_date: date
      #data_process in render_form first. need to call result trigger after index trigger
      @controller.trigger('cvr-dropped-query:index', data)  
      @controller.trigger('cvr-dropped-query:result',data)
    else 
      @controller.trigger('cvr-dropped-query:index')

  search_rel: (query, date_parts) =>
    @set_date_info(date_parts)
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'search-rel:index', query: query)
    else
      @controller.trigger('search-rel:index')

  search_kpi: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('search-kpi:index')
  
  poor_performing: (query, date_parts) =>
    @set_date_info(date_parts)
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'poor-performing:index', query: query)
    else
      @controller.trigger('poor-performing:index')

  adhoc_search: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('search:form')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'load-search-results', query)
    else
      @controller.trigger('adhoc-search:index')
  
  query_monitoring_count: (query, date_parts) =>
    @set_date_info(date_parts)
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'query-monitoring-count:index', query: query)
    else
      @controller.trigger('query-monitoring-count:index')

  query_monitoring_metrics: (query, date_parts) =>
    @set_date_info(date_parts)
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'query-monitoring-metrics:index', query: query)
    else
      @controller.trigger('query-monitoring-metrics:index')

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

