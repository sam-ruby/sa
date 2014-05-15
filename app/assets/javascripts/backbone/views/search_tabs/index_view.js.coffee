Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    $(document).find('#cad-breadcrumb').delegate(
      'ul.search li a', 'click', (e)=>
        @page_nav(e))
    
    @listenTo(@router, 'route:search', (path, filter) =>
      @$el.css('display', 'block')
      query_segment = @segment_lookup[path.search]
      bc_paths = []
      
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

      for metric_db_id, metric of Searchad.Views.SummaryMetrics.prototype.metrics_name
        if metric.id == path.page
          metric_name = metric.name
          metric_id = metric.id
          break

      $(document).find('#cad-breadcrumb').empty()
      if segment_name? and segment_path?
        overview_link = "search/overview"
        segment_overview_link = "search/#{segment_path}/page/overview"
        metric_link = "search/#{segment_path}/page/#{metric_id}"
        
        if metric_id? and path.details == 'sig_comp' and path.query? and path.items?
          query = decodeURIComponent(path.query)
          query_link = "search/#{segment_path}/page/#{metric_id}/" +
            "details/1/query/#{path.query}"
          bc_paths.push(name: 'Overview of Metrics', href: overview_link)
          bc_paths.push(name: segment_name, href: segment_overview_link)
          bc_paths.push(name: metric_name,  href: metric_link)
          bc_paths.push(name: query, href: query_link)
          bc_paths.push(name: 'Signal Comparison', active: true)
        else if metric_id? and parseInt(path.details) == 1 and path.query?
          query = decodeURIComponent(path.query)
          bc_paths.push(name: 'Overview of Metrics', href: overview_link)
          bc_paths.push(name: segment_name, href: segment_overview_link)
          bc_paths.push(name: metric_name,  href: metric_link)
          bc_paths.push(name: query, active: true)
        else if metric_id?
          bc_paths.push(name: 'Overview of Metrics', href: overview_link)
          bc_paths.push(name: segment_name, href: segment_overview_link)
          bc_paths.push(name: metric_name,  active: true)
        else if segment_name != 'Segment Overview'
          bc_paths.push(name: 'Overview of Metrics', href: overview_link)
          bc_paths.push(name: segment_name, active: true)
    
      else if path.search == 'adhoc' and path.query? and path.details == 'sig_comp' and path.items?
        query = decodeURIComponent(path.query)
        search_link = "search/adhoc/query/#{query}"
        bc_paths.push(name: 'Search Results', href: search_link)
        bc_paths.push(name: 'Signal Comparison', active: true)
        
      if bc_paths.length > 0
        $(document).find('#cad-breadcrumb').append(
          JST['backbone/templates/search_bc'](bc_paths: bc_paths) )
    )

  segment_lookup:
      top:
        id: 'TOP QUERIES'
        name: 'Top Queries'
      trend_2:
        id: 'TREND_2'
        name: 'Trending Queries'
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
        name: '30 day Oppor'
      drop_con_1:
        id: 'DROP_CON_1_WK'
        name: 'Opportunities in 1 Week'
      drop_con_2:
        id: 'DROP_CON_2_WK'
        name: 'Opportunities in 2 Weeks'
      drop_con_3:
        id: 'DROP_CON_3_WK'
        name: 'Opportunities in 3 Weeks'
      drop_con_4:
        id: 'DROP_CON_4_WK'
        name: 'Opportunities in 4 Weeks'
      poor_amzn:
        id: 'POOR_QUERIES_AMAZON'
        name: 'Compet Oppor'
      typical_query:
        id: 'TYPICAL_QUERY'
        name: 'Repr Sample'
      all_queries:
        id: 'ALL QUERIES'
        name: 'ALL QUERIES'

  events:
    'click ul.nav li a': 'update_query_segment'

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  unrender: =>
    @$el.hide()
  
  page_nav: (e) =>
    e.preventDefault()
    path  = $(e.target).attr('href')
    @router.update_path(path, trigger: true) if path?

  update_query_segment: (e) =>
    e.preventDefault()
    segment = $(e.target).parents('li').attr('class').replace(
      /(\s+)?(active|dropdown)(\s+)?/, '')
    if segment == 'overview'
      @router.update_path("search/#{segment}", trigger: true)
    else
      @router.update_path("search/#{segment}/page/overview", trigger: true)

