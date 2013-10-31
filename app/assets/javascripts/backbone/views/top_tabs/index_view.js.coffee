Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @select_rel_app)
    @controller.bind('explore:app', @select_explore_app)
    @controller.bind('query-perf-comp:app', @select_query_comp_app)
    @controller.bind('search:app', @select_search_app)
    @masterTabView = new Searchad.Views.MasterTab.IndexView(
        el: 'div.master-tab')

  events:
    'click li.relevance-tab': 'relevance'
    'click li.explore-tab': 'explore'
    'click li.query-comparison-tab': 'query_comparison'
    'click li.search-tab': 'search'
    
  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  relevance: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('relevance:app')
    @controller.trigger('search-kpi:index')
    @router.update_path('search_rel')

  explore: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('explore:app')
    @controller.trigger('comp-analysis:index', saveQuery: false)
    @router.update_path('comp_analysis')
  
  query_comparison: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('query-perf-comp:app')
    @controller.trigger('query-comparison')
    @router.update_path('query_perf_comparison')
 
  search: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search:app')
    @controller.trigger('search:form')
    @router.update_path('search')
  
  select_rel_app: =>
    e = {}
    e.target = @$el.find('li.relevance-tab a').get(0)
    @toggleTab(e)

  select_explore_app: =>
    e = {}
    e.target = @$el.find('li.explore-tab a').get(0)
    @toggleTab(e)
    
  select_query_comp_app: =>
    e = {}
    e.target = @$el.find('li.query-comparison-tab a').get(0)
    @toggleTab(e)
    
  select_search_app: =>
    e = {}
    e.target = @$el.find('li.search-tab a').get(0)
    @toggleTab(e)
   
