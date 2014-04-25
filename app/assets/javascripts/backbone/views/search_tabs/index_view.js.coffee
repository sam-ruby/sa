Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    $(document).find('#cad-breadcrumb').delegate(
      'ul.search li a', 'click', (e)=>
        @update_feature(e))
    
    @listenTo(@router, 'route:search', (path, filter) =>
      @$el.css('display', 'block')
      query_segment = @segment_lookup[path.search]
      if query_segment?
        segment_name = query_segment.name
        segment_db_id = query_segment.id
        segment_path = path.search

        if segment_path.match(/drop_con/)
          route_class = 'poor_perform'
        else if segment_path.match(/trend/)
          route_class = 'trend_2'
        else
          route_class = path.search
      
      if route_class? and segment_db_id?
        @toggleTab(@$el.find("li.#{route_class} a"))
        @controller.set_query_segment(segment_db_id)
      else
        @toggleTab(@$el.find("li.overview a"))

      for metric of Searchad.Views.SummaryMetrics.prototype.metrics_name
        if metric.id == path.page
          metric_name = metric.name
          metric_id = metric.id
          break

      if segment_name? and segment_path?
        bc_paths = []

        if metric_id? and path.details? and path.query?
          query = decodeURIComponent(path.query)
          bc_paths.push(name: 'Overview of Metrics', class: 'overview')
          bc_paths.push(name: segment_name, class: segment_path)
          bc_paths.push(name: metric_name,  class: metric_id)
          bc_paths.push(name: query, active: true)
        else if metric_id?
          bc_paths.push(name: 'Overview of Metrics', class: 'overview')
          bc_paths.push(name: segment_name, class: segment_path)
          bc_paths.push(name: metric_name,  active: true)
        else if segment_name != 'Segment Overview'
          bc_paths.push(name: 'Overview of Metrics', class: 'overview')
          bc_paths.push(name: segment_name, active: true)

        $(document).find('#cad-breadcrumb').empty()
        if bc_paths.length > 0
          $(document).find('#cad-breadcrumb').append(
            JST['backbone/templates/search_bc'](bc_paths: bc_paths) )
    )

  segment_lookup:
      top:
        id: 'TOP QUERIES'
        name: 'Top'
      trend_2:
        id: 'TREND_2'
        name: 'Trending'
      trend_7:
        id: 'TREND_7'
        name: 'Trending in 7 days'
      trend_14:
        id: 'TREND_14'
        name: 'Trending in 14 days'
      trend_21:
        id: 'TREND_21'
        name: 'Trending in 21 days'
      trend_28:
        id: 'TREND_28'
        name: 'Trending in 28 days'
      poor_perform:
        id: 'POOR QUERIES IN 30 DAYS'
        name: '30 day Oppor.'
      drop_con_1:
        id: 'DROP_CON_1_WK'
      drop_con_2:
        id: 'DROP_CON_2_WK'
      drop_con_3:
        id: 'DROP_CON_3_WK'
      drop_con_4:
        id: 'DROP_CON_4_WK'
      poor_amzn:
        id: 'POOR_QUERIES_AMAZON'
        name: 'Comptetive'
      typical_query:
        id: 'TYPICAL_QUERY'
        name: 'Random'


  events:
    'click ul.nav li a': 'update_query_segment'

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  unrender: =>
    @$el.hide()
  
  update_feature: (e) =>
    e.preventDefault()
    feature  = $(e.target).attr('class')
    segment_paths = (segment_id for segment_id, segment  of @segment_lookup)
    curr_path = window.location.hash
    if ((filter_index = curr_path.indexOf('/filters')) != -1)
      filters = curr_path.substring(filter_index)
    
    if feature.match(/overview/i)
      new_path = "search/overview#{filters}"
    else if segment_paths.indexOf(feature) != -1
      new_path = "search/#{feature}/page/overview#{filters}"
    else
      for metric of Searchad.Views.SummaryMetrics.prototype.metrics_name
        if metric.id == feature
          segment = @router.path.search
          new_path = "search/#{segment}/page/#{feature}#{filters}"
          break
    @router.navigate(new_path, trigger: true) if new_path?

  update_query_segment: (e) =>
    e.preventDefault()
    segment = $(e.target).parents('li').attr('class').replace(
      /(\s+)?(active|dropdown)(\s+)?/, '')
    if segment == 'overview'
      @router.update_path("search/#{segment}", trigger: true)
    else
      @router.update_path("search/#{segment}/page/overview", trigger: true)

