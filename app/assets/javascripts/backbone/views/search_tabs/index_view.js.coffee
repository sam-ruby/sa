Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @listenTo(@router, 'route', (route, params) =>
      if route != 'search'
        @unrender()
        return
      @$el.css('display', 'block')

      if @router.task == 'top'
        @toggleTab(@$el.find('li.top-tab a'))
        @controller.set_query_segment('TOP QUERIES')
      else if @router.task == 'trending'
        @controller.set_query_segment('TRENDING QUERIES IN 2 DAYS')
        @toggleTab(@$el.find('li.trending-tab a'))
      else if @router.task == 'poor_performing'
        @controller.set_query_segment('POOR PERFORMING')
        @toggleTab(@$el.find('li.poor-performing-tab a'))
      else if @router.task == 'random'
        @controller.set_query_segment('RANDOM')
        @toggleTab(@$el.find('li.random-tab a'))
      else if @router.task == 'conv_dropped'
        @controller.set_query_segment('CONVERSION DROPPED')
        @toggleTab(@$el.find('li.conv-dropped-tab a'))
    )

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  unrender: =>
    @$el.hide()
