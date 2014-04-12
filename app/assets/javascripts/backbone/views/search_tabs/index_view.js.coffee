Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    $(document).find('#cad-breadcrumb').delegate(
      'ul.search li a', 'click', (e)=>
        @update_feature(e))

    segment_lookup =
      top: 'TOP QUERIES'
      trend_2: 'TREND_2'
      trend_7: 'TREND_7'
      trend_14: 'TREND_14'
      trend_21: 'TREND_21'
      trend_28: 'TREND_28'
      poor_perform: 'POOR QUERIES IN 30 DAYS'
      drop_con_1: 'DROP_CON_1_WK'
      drop_con_2: 'DROP_CON_2_WK'
      drop_con_3: 'DROP_CON_3_WK'
      drop_con_4: 'DROP_CON_4_WK'
      poor_amzn: 'POOR_QUERIES_AMAZON'
      random: 'RANDOM'
      
    feature_names =
      traffic: 'Traffic'
      pvr: 'Product View Rate'
      atc: 'Add To Cart Rate'
      revenue: 'Revenue'
      conversion: 'Conversion'
      conv_cor: 'Conversion Relevance'
    path_name_routes = (key for key, value of feature_names)
    
    @listenTo(@router, 'route:search', (path, filter) =>
      @$el.css('display', 'block')
      for key, value of segment_lookup when path.search == key
        if key.match(/drop_con/)
          route_class = 'poor_perform'
        else if key.match(/trend/)
          route_class = 'trend_2'
        else
          route_class = key
        @toggleTab(@$el.find("li.#{route_class} a"))
        @controller.set_query_segment(value)

      bc_paths = []
      search_page = path.page
      if search_page? and path_name_routes.indexOf(search_page) != -1 and path.details? and path.query?
        query = decodeURIComponent(path.query)
        bc_paths.push(name: 'Overview of Metrics', class: 'overview')
        bc_paths.push(name: feature_names[search_page],  class: search_page)
        bc_paths.push(name: query, active: true)
      else if search_page? and search_page != 'overview'
        bc_paths.push(name: 'Overview of Metrics', class: 'overview')
        bc_paths.push(name: feature_names[search_page], active: true)

      $(document).find('#cad-breadcrumb').empty()
      if bc_paths.length > 0
        $(document).find('#cad-breadcrumb').append(
          JST['backbone/templates/search_bc'](bc_paths: bc_paths) )
    )

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
    curr_path = window.location.hash
    match = /page\/?([^\/]+)?\/?(details\/1)?\/?(query\/[^\/]+)?/.exec(curr_path)
    if match? and match[1]? and match[2]? and match[3]?
      term = "page/#{match[1]}/#{match[2]}/#{match[3]}"
      new_path = curr_path.replace(term, "page/#{feature}")
    else if match? and match[1]? and match[2]?
      term = "page/#{match[1]}/#{match[2]}"
      new_path = curr_path.replace(term, "page/#{feature}")
    else if match? and match[1]?
      term = "page/#{match[1]}"
      new_path = curr_path.replace(term, "page/#{feature}")
    else
      new_path = "search/top/page/overview"
    @router.navigate(new_path, trigger: true)

  update_query_segment: (e) =>
    e.preventDefault()
    segment = $(e.target).parents('li').attr('class').replace(
      /(\s+)?(active|dropdown)(\s+)?/, '')
    @router.update_path("search/#{segment}", trigger: true)
