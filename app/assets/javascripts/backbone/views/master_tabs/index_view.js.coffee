Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @init_relevance)
    @controller.bind('explore:app', @init_explore)
    @controller.bind('query-perf-comp:app', @init_query_perf_comp)
    #@controller.bind('search:app', @init_search)

    @controller.bind('poor-performing:index', @select_pp_tab)
    @controller.bind('search-rel:index', @select_sq_tab)
    @controller.bind('search-kpi:index', @select_search_kpi_tab)
    @controller.bind('comp-analysis:index', @select_ca_tab)
    @controller.bind('query-perf-comp:index', @select_query_perf_comparison_tab)
    @controller.bind('adhoc-search:index', @select_search_tab)
    # @controller.bind('query-comparison', @select_query_perf_comparison_tab)
    # @controller.bind('search', @select_search_tab)

  events:
    #events on overview page
    'click li.search-quality-tab': 'searchQuality'
    'click li.poor-performing-tab': 'poorPerforming'
    'click li.search-kpi-tab': 'searchKPI'
    'click li.comp-analysis-tab': 'compAnalysis'
    #tab on adhoc query analysis page
    'click li.query-perf-comparison-tab':'queryPerfComp'
    'click li.adhoc-search-tab':'adhocSearchQuery'
    
  get_tab_el: (data) ->
    css_classes = data.class.join(' ')
    tab =
      $("<li class='#{css_classes}'><a href='#{data.href}'>#{data.title}</a></li>")
  
  init_relevance: =>
    @clean_tabs()
    tabs = [{
      class: ['active', 'search-kpi-tab']
      href: '#search_kpi'
      title: 'KPI'},
      {class: ['search-quality-tab']
      href: '/#search_rel'
      title: 'Query Analysis'},
      {class: ['poor-performing-tab']
      href: '#poor_performing'
      title: 'Poor Performing Intents'}]

    
    @$el.find('ul').prepend(@get_tab_el(tabs[2]))
    @$el.find('ul').prepend(@get_tab_el(tabs[1]))
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

  init_explore: =>
    @clean_tabs()
    ###
    tabs = [{
      class: ['comp-analysis-tab']
      href: '/#comp_analysis'
      title: 'Amazon Relevance Comparison'}]
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))
    ###
    @$el.find('ul').hide()
  
  init_search: =>
    @clean_tabs()
    @$el.find('ul').hide()

  init_query_perf_comp: =>
   
    @clean_tabs()
    tabs = [{
      class: ['query-perf-comparison-tab','active']
      href: '#query-perf-comparison'
      title: 'Query Performace Analysis'},
      {class: ['adhoc-search-tab']
      href: '#search'
      title: 'Search'}]
    @$el.find('ul').prepend(@get_tab_el(tabs[1]))
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

    ###
    tabs = [{
      class: ['query-comparison-details-tab']
      href: '/#query_perf_comparison'
      title: 'Details'}]
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))
    ###
   # @$el.find('ul').hide()
  
  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  queryComparison: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('query-comparison')
    @router.update_path('query_perf_comparison')

  searchQuality: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search-rel:index')
    @router.update_path('search_rel')

  searchKPI: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search-kpi:index')
    @router.update_path('search_kpi')
  
  poorPerforming: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('poor-performing:index', trigger: true)

  compAnalysis: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('comp-analysis:index')
    @router.update_path('comp_analysis')

  #adhoc query page
  adhocSearchQuery: (e)=>
    console.log("clicked search query")
    e.preventDefault()
    #switch to search tab
    @controller.trigger('adhoc-search:index')
    @controller.trigger('content-cleanup')
    e.preventDefault()
    #switch to search app
    @controller.trigger('search:app')
    @controller.trigger('search:form')
    @router.update_path('search')
  
  #adhoc query page
  queryPerfComp: (e)=>
    #switch to queryPerfComp in adhoc page
    @controller.trigger('query-perf-comp:index')
    e.preventDefault()
    #update the content
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('query-perf-comp:app')
    @controller.trigger('query-comparison')

  
  select_pp_tab: =>
    e = {}
    e.target = @$el.find('li.poor-performing-tab a').get(0)
    @toggleTab(e)
 
  select_sq_tab: =>
    e = {}
    e.target = @$el.find('li.search-quality-tab a').get(0)
    @toggleTab(e)
   
  select_search_kpi_tab: =>
    e = {}
    e.target = @$el.find('li.search-kpi-tab a').get(0)
    @toggleTab(e)
  
  select_ca_tab: =>
    e = {}
    e.target = @$el.find('li.comp-analysis-tab a').get(0)
    @toggleTab(e)
 
  select_query_comp_tab: =>
    e = {}
    e.target = @$el.find('li.query-comparison-details-tab a').get(0)
    @toggleTab(e)

#on ad-hoc analysis page
  select_query_perf_comparison_tab:=>
    e = {}
    e.target = @$el.find('li.query-perf-comparison-tab a').get(0)
    @toggleTab(e)

  select_search_tab:=>
    e = {}
    e.target = @$el.find('li.adhoc-search-tab a').get(0)
    @toggleTab(e)

  clean_tabs: =>
    @$el.find('li').remove()
    @$el.find('ul').show()


