class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  routes:
    "search_rel(/query/:query)(/filters/*wday)": "search_rel"
    "search_rel/item_id/:id(/filters/*wday)": "search_query_items"
    
    "search_kpi(/filters/*wday)": "search_kpi"
    "(filters/*wday)": "search_kpi"
    
    "poor_performing(/query/:query)(/filters/*wday)": "poor_performing"
    
    # "search(/query/:query)(/filters/*wday)": "adhoc_search"
    
    "query_monitoring/count(/query/:query)(/filters/*wday)":
      "query_monitoring_count"
    "query_monitoring/metrics(/query/:query)(/filters/*wday)":
      "query_monitoring_metrics"

    "adhoc_query/mode/search(/query)(/)(:query)(/filters/*wday)":
      "adhoc_query_search"
    "adhoc_query(/mode/query_comparison)(/wks_apart/:weeks)(/query_date/:date)(/query)(/)(:query)(/filters/*wday)":
      "adhoc_query_comparison"

  set_date_info: (date_part) =>
    curr_date = $('#dp3').datepicker('getDate')
    if date_part?
      date_parts = date_part.split('/')
      for part, i in date_part.split('/')
        if part == 'date'
          if curr_date != Selected_Date
            @controller.trigger('update_date', date_parts[i+1])
            @controller.set_date(date_parts[i+1])
        else if part == 'year'
          @controller.set_year(date_parts[i+1])
        else if part == 'week'
          @controller.set_week(date_parts[i+1])
    else if curr_date != Selected_Date
      @controller.trigger('update_date', Selected_Date.toString('M-d-yyyy'))


  adhoc_query_comparison: (weeks, date, query) =>
    data=
      weeks_apart: weeks
      query_date: date
      query: query
    @controller.trigger('adhoc-query:index',data)
    @controller.trigger('adhoc:toggle_search_mode', true)
    @controller.trigger('adhoc:cvr_dropped_query', data)

  adhoc_query_search:(query) =>
    data=
      query: query
    @controller.trigger('adhoc-query:index',data)
    console.log("adhoc_query_search><")
    @controller.trigger('adhoc:toggle_search_mode', false)
    @controller.trigger('adhoc:search', data)



  search_rel: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'search-rel:index', query: query)
    else
      @controller.trigger('search-rel:index')

  search_kpi: (date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    @controller.trigger('search-kpi:index')
  
  poor_performing: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'poor-performing:index', query: query)
    else
      @controller.trigger('poor-performing:index')

  adhoc_search: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    @controller.trigger('search:form')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'load-search-results', query)
    else
      @controller.trigger('adhoc-search:index')
  
  query_monitoring_count: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'query-monitoring-count:index', query: query)
    else
      @controller.trigger('query-monitoring-count:index')

  query_monitoring_metrics: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'query-monitoring-metrics:index', query: query)
    else
      @controller.trigger('query-monitoring-metrics:index')

  update_path: (path, options=null) =>
    url_parts = window.location.hash.replace('#', '').split('filters')
    if url_parts.length > 0
      filters = url_parts[1]
    curr_path = url_parts[0]
    new_path = path
    if filters
      if new_path.indexOf('/') != (new_path.length - 1)
        new_path += '/'
      new_path += 'filters' + filters
    options = {} unless options?
    options['trigger'] ||= false
    @navigate(new_path, options)

