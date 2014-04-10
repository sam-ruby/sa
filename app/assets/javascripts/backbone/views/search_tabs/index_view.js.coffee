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
      if path.search == 'top'
        @toggleTab(@$el.find('li.top a'))
        @controller.set_query_segment('TOP QUERIES')
      else if path.search == 'trending'
        @controller.set_query_segment('TRENDING QUERIES IN 2 DAYS')
        @toggleTab(@$el.find('li.trending a'))
      else if path.search == 'poor_performing'
        @controller.set_query_segment('POOR QUERIES IN 30 DAYS')
        @toggleTab(@$el.find('li.poor_performing a'))
      else if path.search == 'random'
        @controller.set_query_segment('RANDOM')
        @toggleTab(@$el.find('li.random a'))
      else if path.search == 'conv_dropped'
        @controller.set_query_segment('CONVERSION DROPPED')
        @toggleTab(@$el.find('li.conv_dropped a'))
      bc_paths = []
      path_names =
        traffic: 'Traffic'
        pvr: 'Product View Rate'
        atc: 'Add To Cart Rate'
        revenue: 'Revenue'
        conversion: 'Conversion'
        conv_cor: 'Conversion Relevance'
      
      path_name_routes = (key for key, value of path_names)
      search_page = path.page
      
      if !search_page? or search_page == 'overview'
        bc_paths.push(name: 'Overview of Metrics', active: true)
      else if search_page? and path_name_routes.indexOf(search_page) != -1 and path.details?
        bc_paths.push(name: 'Overview of Metrics', class: 'overview')
        bc_paths.push(name: path_names[search_page],  class: search_page)
        bc_paths.push(name: "Details", active: true)
      else if search_page? and search_page != 'overview'
        bc_paths.push(name: 'Overview of Metrics', class: 'overview')
        bc_paths.push(name: path_names[search_page], active: true)

      $(document).find('#cad-breadcrumb').empty()
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
    segment = $(e.target).parents('li').attr('class')
    segment = segment.replace(' active')
    @router.update_path("search/#{segment}", trigger: true)
