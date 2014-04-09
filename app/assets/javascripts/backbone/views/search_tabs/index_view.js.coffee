Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
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
    )

  events:
    'click ul.nav li a': 'update_query_segment'

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  unrender: =>
    @$el.hide()
  
  update_query_segment: (e) =>
    e.preventDefault()
    segment = $(e.target).parents('li').attr('class')
    segment = segment.replace(' active')
    curr_path = window.location.hash
    match = /search\/?([^\/]+)?/.exec(curr_path)
    if match? and match[1]?
      term = "search/#{match[1]}"
      new_path = curr_path.replace(term, "search/#{segment}")
    else if match?
      term = 'search'
      new_path = curr_path.replace(term, "search/#{segment}")
    else
      new_path = "search/#{segment}"
    @router.update_path(new_path, trigger: true)
