class Searchad.Routers.SearchQualityQuery extends Backbone.Router
  initialize: (options) ->
    @controller = SearchQualityApp.Controller

  routes:
    "search(/:task)(/:sub_task)(/*args)": "search"
    "browse(/:task)(/:sub_task)(/*args)": "browse"
    "category(/:task)(/:sub_task)(/*args)": "category"
    "search_rel(/query/:query)(/filters/*wday)": "search_rel"
    "search_rel/item_id/:id(/filters/*wday)": "search_query_items"
    
    "search_kpi(/filters/*wday)": "search_kpi"
    
    "trending(/query/:query)(/filters/*wday)": "trending"
    "trending/up(/query/:query)(/filters/*wday)": "up_trending"
    "trending/up(/query/:query)(/days/:days)(/filters/*wday)": "up_trending_days"
    "(filters/*wday)": "trending"
    
    "query_monitoring/count(/query/:query)(/filters/*wday)":
      "query_monitoring_count"
    "query_monitoring/metrics(/query/:query)(/filters/*wday)":
      "query_monitoring_metrics"

    "adhoc_query/mode/search(/query/)(:query)(/filters/*wday)":
      "adhoc_query_search"
    "adhoc_query(/mode/query_comparison)(/wks_apart/:weeks/query_date/:date/query/)(:query)(/filters/*wday)":
      "adhoc_query_comparison"

  get_cat_id: (filters) ->
    if filters?
      parts = filters.split('/')
      for part, i in parts
        if part == 'cat_path'
          cat_path = parts[i+1]
          cats = cat_path.split(/_/)
          @cat_id = cats[cats.length-1] if cats? and cats.length > 0
          @cat_path = cat_path if cat_path?
    @cat_id ||=0
  
  set_date_info: (date_part) =>
    @get_cat_id(date_part)
    curr_date = $('#dp3').datepicker('getDate')
    return unless date_part?
    
    arg = date_part.match(/filters/)
    return unless arg? or arg.length == 0
    date_part = date_part.split(/filters/)[1]
    date_parts = date_part.split('/')
    
    for part, i in date_parts
      if part == 'date' and date_parts[i+1]?
        @controller.trigger('update_date', date_parts[i+1])
        @controller.set_date(date_parts[i+1])

  search:(@task, @sub_task, @task_args) =>
    @set_date_info(@task_args)

  browse:(@task, @sub_task, @task_args) =>
    @set_date_info(@task_args)
  
  catalog:(@task, @sub_task, @task_args) =>
    @set_date_info(@task_args)
  
  adhoc_query_comparison: (weeks, date, query, date_parts) =>
    @set_date_info(date_parts)
    data=
      weeks_apart: weeks
      query_date: date
      query: query
    @controller.trigger('adhoc:index',data)
    @controller.trigger('adhoc:toggle_search_mode', true)
    # always trigger cvr_dropped_query, if there is no query, by default it will get top 500
    @controller.trigger('adhoc:cvr_dropped_query', data)


  adhoc_query_search:(query, date_parts) =>
    @set_date_info(date_parts)
    data=
      query: query
    @controller.trigger('adhoc:index',data)
    @controller.trigger('adhoc:toggle_search_mode', false)
    # only trigger search when there is query 
    if query
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
  
  trending: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'trending:index', query: query)
    else
      @controller.trigger('trending:index')

  up_trending_days: (query, days, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query? and days?
      query = decodeURIComponent(query)
      @controller.trigger('up-trending:index',
        days: days
        query: query)
    else if query?
      query = decodeURIComponent(query)
      @controller.trigger('up-trending:index', query: query)
    else if days?
      query = decodeURIComponent(query)
      @controller.trigger('up-trending:index', days: days)
    else
      @controller.trigger('up-trending:index')

  up_trending: (query, date_parts) =>
    @set_date_info(date_parts)
    @controller.trigger('master-tabs:cleanup')
    @controller.trigger('content-cleanup')
    if query?
      query = decodeURIComponent(query)
      @controller.trigger(
        'up-trending:index', query: query)
    else
      @controller.trigger('up-trending:index')

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
        'qm-metrics:index', query: query)
    else
      @controller.trigger('qm-metrics:index')

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

  # this function will return the basic root url. 
  # like /#adhoc_query or /#search_rel etc
  get_root_path: =>
    url = window.location.hash
    if url.match(/^#[^\/]*/)
      url.match(/^#[^\/]*/)[0]
    else
      ""
  
  root_path_contains:(url_regexp) =>
    url = window.location.hash
    if url.match(url_regexp)
      true
    else
      false

