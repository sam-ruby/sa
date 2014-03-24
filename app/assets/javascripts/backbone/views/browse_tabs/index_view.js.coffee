Searchad.Views.BrowseTabs ||= {}

class Searchad.Views.BrowseTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @listenTo(@router, 'route', (route, params) =>
      if route != 'browse'
        @unrender()
        return

      if @router.task == 'analysis'
        @query_analysis()
    )
    
  events: =>
    'click li.query-performance-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/browse/analyis', trigger: true)
  
  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  render: =>
    return unless @active
    @$el.css('display', 'block')
    @delegateEvents()

  unrender: =>
    @active = false
    @$el.hide()

  query_analysis: =>
    @active = true
    @render()
    @toggleTab(@$el.find('li.query-analysis-tab a'))

