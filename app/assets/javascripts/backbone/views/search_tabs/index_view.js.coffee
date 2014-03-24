Searchad.Views.SearchTabs ||= {}

class Searchad.Views.SearchTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @listenTo(@router, 'route', (route, params) =>
      if route != 'search'
        @unrender()
        return
      
      if @router.task == 'analysis'
        @query_analysis()
      else if @router.task == 'ndcg'
        @ndcg()
      else
        @query_performance()
    )

  events: =>
    'click li.query-performance-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/search/performance/poor_performing',
        trigger: true)

    'click li.query-analysis-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/search/analysis', trigger: true)

    'click li.ndcg-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/search/ndcg', trigger: true)
   
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

  query_performance: =>
    @active = true
    @render()
    @toggleTab(@$el.find('li.query-performance-tab a'))

  query_analysis: =>
    @active = true
    @render()
    @toggleTab(@$el.find('li.query-analysis-tab a'))
  
  ndcg: (e, data) =>
    @active = true
    @render()
    @toggleTab(@$el.find('li.ndcg-tab a'))
  
