Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @select_rel_app)
    @controller.bind('explore:app', @select_explore_app)
    @controller.bind('query-perf-comp:app', @select_adhoc_query_analysis_app)
    @masterTabView = new Searchad.Views.MasterTab.IndexView(
        el: 'div.master-tab')

  events:
    'click li.relevance-tab': 'relevance'
    'click li.explore-tab': 'explore'
    'click li.adhoc-query-analysis-tab': 'adhoc_query_analysis'
    
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
  
  adhoc_query_analysis: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('query-perf-comp:app')
    @controller.trigger('query-comparison')
    @router.update_path('query_perf_comparison')
  
  select_rel_app: =>
    e = {}
    e.target = @$el.find('li.relevance-tab a').get(0)
    @toggleTab(e)

  select_explore_app: =>
    e = {}
    e.target = @$el.find('li.explore-tab a').get(0)
    @toggleTab(e)
    
  select_adhoc_query_analysis_app: =>
    e = {}
    e.target = @$el.find('li.adhoc-query-analysis-tab a').get(0)
    @toggleTab(e)
    
   
