Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('search-kpi:index', @overview)
    @controller.bind('search-rel:index', @overview)
    @controller.bind('trending:index', @overview)
    @controller.bind('trending-up:index', @overview)
    @controller.bind('adhoc:index', @adhoc)
    @controller.bind('query-monitoring-count:index', @query_monitoring)
    @controller.bind('qm-metrics:index', @query_monitoring)
    
    @masterTabView = new Searchad.Views.MasterTab.IndexView(
        el: 'ul.master-tab')
  
  events: =>
    'click li.overview-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('master-tabs:cleanup')
      @controller.trigger('content-cleanup')
      @controller.trigger('trending:index')
      @router.update_path('/')

    'click li.adhoc-query-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('master-tabs:cleanup')
      @controller.trigger('content-cleanup')
      @controller.trigger('adhoc:index')
      @controller.trigger('adhoc:cvr_dropped_query')
      @controller.trigger('adhoc:toggle_search_mode', true)
      @router.update_path('adhoc_query/mode/query_comparison')

    'click li.query-monitoring-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('master-tabs:cleanup')
      @controller.trigger('content-cleanup')
      @controller.trigger('query-monitoring-count:index')
      @router.update_path('query_monitoring/count')
   
  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  overview: =>
    @toggleTab(@$el.find('li.overview-tab a'))

  adhoc: =>
    @toggleTab(@$el.find('li.adhoc-query-tab a'))
  
  query_monitoring: (e, data) =>
    @toggleTab(@$el.find('li.query-monitoring-tab a'))
  
